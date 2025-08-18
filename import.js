// import.js
// Idempotent Firebase importer for colleges.json produced by build_colleges.js
// Writes documents with both camelCase and snake_case aliases for app compatibility.

import fs from "fs";
import path from "path";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

// ---- Replace with your Firebase service account JSON path or set env var GOOGLE_APPLICATION_CREDENTIALS
let SERVICE_ACCOUNT_PATH = process.env.GOOGLE_APPLICATION_CREDENTIALS || "./serviceAccount.json";
// Fallback to serviceAccountKey.json if default not present
try {
  const p = path.isAbsolute(SERVICE_ACCOUNT_PATH)
    ? SERVICE_ACCOUNT_PATH
    : path.join(process.cwd(), SERVICE_ACCOUNT_PATH);
  fs.accessSync(p);
} catch (_) {
  const alt = path.join(process.cwd(), "serviceAccountKey.json");
  try {
    fs.accessSync(alt);
    SERVICE_ACCOUNT_PATH = alt;
    console.log(`Using service account: ${SERVICE_ACCOUNT_PATH}`);
  } catch {
    // leave as-is; will error later with helpful message
  }
}

// ---- Collection names
const COLLEGES_COLL = "colleges";
const META_COLL = "collegesMeta";

function requireJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf-8"));
}

function aliasKeys(c) {
  // Provide both camelCase and snake_case keys where the app is inconsistent
  const out = { ...c };
  // Derive location if missing
  if (!out.location && out.city && out.state) out.location = `${out.city}, ${out.state}`;
  // Ranking aliases
  if (out.nirfRank != null) out["nirf_rank"] = out.nirfRank;
  if (out.overallRank != null) out["overall_rank"] = out.overallRank;
  // Fees/period
  if (out.feesPeriod != null) out["fees_period"] = out.feesPeriod;
  // Misc numeric/string fields
  if (out.reviewCount != null) out["review_count"] = out.reviewCount;
  if (out.admissionProcess != null) out["admission_process"] = out.admissionProcess;
  if (out.cutoffScore != null) out["cutoff_score"] = out.cutoffScore;
  if (out.placementRate != null) out["placement_rate"] = out.placementRate;
  if (out.averagePackage != null) out["average_package"] = out.averagePackage;
  if (out.highestPackage != null) out["highest_package"] = out.highestPackage;
  if (out.hostelFees != null) out["hostel_fees"] = out.hostelFees;
  if (out.hasHostel != null) out["has_hostel"] = out.hasHostel;
  if (out.shortName != null) out["short_name"] = out.shortName;
  if (out.imageUrl != null) out["image_url"] = out.imageUrl;
  if (out.establishedYear != null) out["established_year"] = out.establishedYear;
  // createdAt alias will be set via server timestamp below
  return out;
}

(async () => {
  const absCreds = path.isAbsolute(SERVICE_ACCOUNT_PATH)
    ? SERVICE_ACCOUNT_PATH
    : path.join(process.cwd(), SERVICE_ACCOUNT_PATH);
  const creds = requireJson(absCreds);
  initializeApp({ credential: cert(creds) });
  const db = getFirestore();

  const payload = requireJson(path.join(process.cwd(), "colleges.json"));
  const { colleges, dataVersion, lastUpdated } = payload;

  let created = 0,
    updated = 0;
  const batchSize = 400;
  for (let i = 0; i < colleges.length; i += batchSize) {
    const slice = colleges.slice(i, i + batchSize);
    const batch = db.batch();
    // Fetch existence sequentially before batching sets
    const refsAndData = [];
    for (const c of slice) {
      const id = c.name.replace(/[^a-z0-9]+/gi, "_").toLowerCase().slice(0, 120);
      const ref = db.collection(COLLEGES_COLL).doc(id);
      const d = aliasKeys({ ...c });
      // Ensure ordering fields present
      if (d.overallRank == null && d.nirfRank != null) {
        d.overallRank = d.nirfRank;
        d["overall_rank"] = d.nirfRank;
      }
      // Timestamps and versions
      d.lastUpdated = new Date().toISOString().slice(0, 10);
      d.dataVersion = dataVersion || d.dataVersion || "v1.0";
      d.createdAt = FieldValue.serverTimestamp();
      d["created_at"] = d.createdAt;

      refsAndData.push({ ref, data: d });
    }

    for (const { ref, data } of refsAndData) {
      const snap = await ref.get();
      if (snap.exists) {
        batch.set(ref, data, { merge: true });
        updated++;
      } else {
        batch.set(ref, data, { merge: false });
        created++;
      }
    }

    await batch.commit();
  }

  // Metadata
  const metaRef = db.collection(META_COLL).doc("summary");
  await metaRef.set(
    {
      totalColleges: colleges.length,
      lastFullImport: new Date().toISOString(),
      dataVersion: dataVersion || "v1.0",
    },
    { merge: true }
  );

  console.log(`Import Complete:\n- Total in file: ${colleges.length}\n- Created: ${created}\n- Updated: ${updated}\n- Data Version: ${dataVersion}\n- Last Updated: ${lastUpdated}`);
})();
