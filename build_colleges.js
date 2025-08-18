// build_colleges.js
// Node 18+ recommended
// Quickly builds a 200+ college dataset from official NIRF lists across streams.
// Outputs: ./colleges.json  (Firebase-ready core fields)

import fs from "fs";
import path from "path";
import { URL as NodeURL } from "url";

// Use Node 18+ global fetch; no dependency needed
const fetchFn = globalThis.fetch;
if (!fetchFn) {
  console.error("This script requires Node 18+ with global fetch.");
  process.exit(1);
}

// Try to parse JSON-like arrays embedded in JS files
function parseEmbeddedJsData(jsText, cat) {
  try {
    const rows = [];
    // Look for JSON arrays assigned to variables: var X = [...] or const X = [...]
    const arrayMatches = jsText.match(/=\s*\[\s*\{[\s\S]*?\}\s*\]\s*[;\n]/g) || [];
    for (const m of arrayMatches) {
      const jsonStr = (m.match(/\[\s*\{[\s\S]*\}\s*\]/) || [])[0];
      if (!jsonStr) continue;
      let arr;
      try { arr = JSON.parse(jsonStr); } catch { continue; }
      if (!Array.isArray(arr)) continue;
      // Check if objects look like ranking rows
      for (const o of arr) {
        const obj = typeof o === 'object' && o ? o : {};
        const get = (...keys) => { for (const k of keys) { const v = obj[k]; if (v !== undefined && v !== null && String(v).trim() !== '') return String(v);} return undefined; };
        const rank = parseInt(get('rank','overall_rank','Overall Rank')||'',10);
        const name = get('name','institute_name','Institute Name','Name of Institute');
        const city = get('city','City','City/Town');
        const state = get('state','State','State/UT');
        const score = parseFloat((get('score','overall_score','Overall Score')||'').replace(/[^\d.]/g,''));
        if (!Number.isFinite(rank) || !Number.isFinite(score)) continue;
        if (!/[A-Za-z]/.test(name||'') || !/[A-Za-z]/.test(city||'') || !/[A-Za-z]/.test(state||'')) continue;
        rows.push({ rank, name: name.trim(), city: city.trim(), state: state.trim(), score, nirfCategory: cat });
      }
    }
    return rows;
  } catch { return []; }
}

// Try to discover a JSON/CSV endpoint from a NIRF page
async function tryFetchEndpoint({ cat, url }) {
  try {
    // 0) Check overrides file first
    let overrideMap = null;
    try {
      const p = path.join(process.cwd(), 'nirf_endpoints.json');
      if (fs.existsSync(p)) {
        overrideMap = JSON.parse(fs.readFileSync(p, 'utf8'));
      }
    } catch (_) {}
    if (overrideMap && overrideMap[cat]) {
      const endpoints = Array.isArray(overrideMap[cat]) ? overrideMap[cat] : [overrideMap[cat]];
      for (const ep of endpoints) {
        try {
          const raw = await fetchWithUA(ep);
          if (/\.json(\?|$)/i.test(ep)) {
            let data; try { data = JSON.parse(raw); } catch { data = null; }
            if (data) {
              const arr = Array.isArray(data) ? data : (Array.isArray(data?.data) ? data.data : []);
              const rows = [];
              for (const o of arr) {
                const obj = typeof o === 'object' && o ? o : {};
                const get = (...keys) => { for (const k of keys) { const v = obj[k]; if (v !== undefined && v !== null && String(v).trim() !== '') return String(v);} return undefined; };
                const rank = parseInt(get('rank','overall_rank','Overall Rank')||'',10);
                const name = get('name','institute_name','Institute Name','Name of Institute');
                const city = get('city','City','City/Town');
                const state = get('state','State','State/UT');
                const score = parseFloat((get('score','overall_score','Overall Score')||'').replace(/[^\d.]/g,''));
                if (!Number.isFinite(rank) || !Number.isFinite(score)) continue;
                if (!/[A-Za-z]/.test(name||'') || !/[A-Za-z]/.test(city||'') || !/[A-Za-z]/.test(state||'')) continue;
                rows.push({ rank, name: name.trim(), city: city.trim(), state: state.trim(), score, nirfCategory: cat });
              }
              if (rows.length) return rows;
            }
          } else if (/\.csv(\?|$)/i.test(ep)) {
            const rows = parseCsvToRows(raw, cat);
            if (rows.length) return rows;
          } else if (/\.js(\?|$)/i.test(ep)) {
            const rows = parseEmbeddedJsData(raw, cat);
            if (rows.length) return rows;
          }
        } catch {}
      }
    }

    const html = await fetchWithUA(url);
    // 0.5) Try inline script-embedded arrays within the page
    {
      const inlineRows = parseEmbeddedJsData(html, cat);
      if (inlineRows.length) return inlineRows;
    }
    // Look for JSON or CSV links in the page
    const links = Array.from(html.matchAll(/href\s*=\s*(["'])(.*?)\1/gi)).map((m) => m[2]);
    const scripts = Array.from(html.matchAll(/src\s*=\s*(["'])(.*?)\1/gi)).map((m) => m[2]);
    const candidates = [...links, ...scripts].filter(Boolean);
    // Sort preference: JSON first, then CSV, then JS
    const sorted = candidates.sort((a,b) => {
      const wt = (h) => (/\.json(\?|$)/i.test(h) ? 0 : (/\.csv(\?|$)/i.test(h) ? 1 : (/\.js(\?|$)/i.test(h) ? 2 : 3)));
      return wt(a) - wt(b);
    });
    for (let endpoint of sorted) {
      try {
        const base = new NodeURL(url);
        endpoint = new NodeURL(endpoint, base).toString();
      } catch (_) {}
      try {
        const raw = await fetchWithUA(endpoint);
        if (/\.json(\?|$)/i.test(endpoint)) {
          // Parse JSON
          let data;
          try { data = JSON.parse(raw); } catch { data = null; }
          const arr = data ? (Array.isArray(data) ? data : (Array.isArray(data?.data) ? data.data : [])) : [];
          const rows = [];
          for (const o of arr) {
            const obj = typeof o === 'object' && o ? o : {};
            const get = (...keys) => { for (const k of keys) { const v = obj[k]; if (v !== undefined && v !== null && String(v).trim() !== '') return String(v);} return undefined; };
            const rank = parseInt(get('rank','overall_rank','Overall Rank')||'',10);
            const name = get('name','institute_name','Institute Name','Name of Institute');
            const city = get('city','City','City/Town');
            const state = get('state','State','State/UT');
            const score = parseFloat((get('score','overall_score','Overall Score')||'').replace(/[^\d.]/g,''));
            if (!Number.isFinite(rank) || !Number.isFinite(score)) continue;
            if (!/[A-Za-z]/.test(name||'') || !/[A-Za-z]/.test(city||'') || !/[A-Za-z]/.test(state||'')) continue;
            rows.push({ rank, name: name.trim(), city: city.trim(), state: state.trim(), score, nirfCategory: cat });
          }
          if (rows.length) return rows;
        } else if (/\.csv(\?|$)/i.test(endpoint)) {
          const rows = parseCsvToRows(raw, cat);
          if (rows.length) return rows;
        } else if (/\.js(\?|$)/i.test(endpoint)) {
          const rows = parseEmbeddedJsData(raw, cat);
          if (rows.length) return rows;
        }
      } catch (_) { /* try next */ }
    }
    return null;
  } catch (_) {
    return null;
  }
}

// Minimal CSV parser that handles quoted fields and commas
function parseCsv(text) {
  const lines = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n').filter((l) => l.trim().length > 0);
  const out = [];
  for (const line of lines) {
    const row = [];
    let i = 0;
    while (i < line.length) {
      if (line[i] === '"') {
        // quoted field
        let j = i + 1, val = '';
        while (j < line.length) {
          if (line[j] === '"' && line[j + 1] === '"') { val += '"'; j += 2; continue; }
          if (line[j] === '"') { j++; break; }
          val += line[j++];
        }
        // skip comma
        if (line[j] === ',') j++;
        row.push(val);
        i = j;
      } else {
        let j = i;
        while (j < line.length && line[j] !== ',') j++;
        row.push(line.slice(i, j).trim());
        i = j + 1;
      }
    }
    out.push(row);
  }
  return out;
}

function parseCsvToRows(csvText, cat) {
  try {
    const rows = parseCsv(csvText);
    if (rows.length < 2) return [];
    const headers = rows[0].map((h) => h.trim().toLowerCase());
    const idx = {};
    headers.forEach((h, i) => {
      const clean = h.replace(/[^a-z/ ]/g, "");
      if (/^rank\b|overall\s*rank/.test(clean)) idx.rank = i;
      else if (/(^|\s)(name of (the )?institute|institute name|name|college name|university name)(\s|$)/.test(clean)) idx.name = i;
      else if (/(^|\s)(city|city\/town)(\s|$)/.test(clean)) idx.city = i;
      else if (/(^|\s)(state|state\/ut)(\s|$)/.test(clean)) idx.state = i;
      else if (/(^|\s)(score|overall\s*score|nirf\s*score)(\s|$)/.test(clean)) idx.score = i;
    });
    const haveAll = ["rank", "name", "city", "state", "score"].every((k) => Number.isInteger(idx[k]));
    if (!haveAll) return [];
    const out = [];
    for (let r = 1; r < rows.length; r++) {
      const row = rows[r];
      const rank = parseInt((row[idx.rank] || '').replace(/[^\d]/g, ''), 10);
      const score = parseFloat((row[idx.score] || '').replace(/[^\d.]/g, ''));
      const name = String(row[idx.name] || '').trim();
      const city = String(row[idx.city] || '').trim();
      const state = String(row[idx.state] || '').trim();
      if (!Number.isFinite(rank) || !Number.isFinite(score)) continue;
      if (!/[A-Za-z]/.test(name) || !/[A-Za-z]/.test(city) || !/[A-Za-z]/.test(state)) continue;
      out.push({ rank, name, city, state, score, nirfCategory: cat });
    }
    return out;
  } catch { return []; }
}

// ---- Config ----
const DATA_VERSION = "v1.0";
const LAST_UPDATED = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

// Category discovery: probe base and rank-band pages ("", 150, 200, 250) and persist
const CATEGORY_NAMES = [
  "Overall",
  "University",
  "College",
  "Engineering",
  "Management",
  "Medical",
  "Pharmacy",
  "Architecture",
  "Law",
  "Dental",
  "Agriculture",
];

async function probeHasTable(url) {
  try {
    const res = await fetchFn(url, {
      redirect: "follow",
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
        Accept:
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        Connection: "keep-alive",
      },
    });
    if (!res.ok) return false;
    const html = await res.text();
    if (!/<table/i.test(html)) return false;
    // ensure at least one body row
    const hasBodyRow = /<tr[^>]*>\s*(?:<(?:td|th)[^>]*>)[\s\S]*?<\/tr>/i.test(html) && /<td/i.test(html);
    return !!hasBodyRow;
  } catch {
    return false;
  }
}

async function discoverCategories(year = 2024) {
  const cachePath = path.join(process.cwd(), "nirf_discovered_endpoints.json");
  // Load cache if present
  try {
    if (fs.existsSync(cachePath)) {
      const cached = JSON.parse(fs.readFileSync(cachePath, "utf8"));
      if (Array.isArray(cached) && cached.every((x) => x && x.cat && x.url)) {
        console.log(`[NIRF] Using cached discovered endpoints: ${cached.length}`);
        return cached;
      }
    }
  } catch {}

  const bands = ["", "150", "200", "250"];
  const discovered = [];
  const seen = new Set();
  for (const cat of CATEGORY_NAMES) {
    for (const band of bands) {
      const url = `https://www.nirfindia.org/Rankings/${year}/${cat}Ranking${band}.html`;
      // polite throttle ~3 req/s
      await new Promise((r) => setTimeout(r, 350));
      const ok = await probeHasTable(url);
      if (ok) {
        const key = `${cat}::${url}`;
        if (!seen.has(key)) {
          discovered.push({ cat, url });
          seen.add(key);
          console.log(`[NIRF] Discovered: ${cat} -> ${url}`);
        }
      }
    }
  }
  // Persist
  try { fs.writeFileSync(cachePath, JSON.stringify(discovered, null, 2)); } catch {}
  return discovered;
}

// Heuristics to infer broad category tag → our app "category"
function inferCategoryTag(nirfCategory, name) {
  if (nirfCategory === "Engineering") return "Engineering";
  if (nirfCategory === "Management") return "Management/MBA";
  if (nirfCategory === "Medical") return "Medical/MBBS";
  if (nirfCategory === "Pharmacy") return "Pharmacy/B.Pharma";
  if (nirfCategory === "Architecture") return "Architecture/B.Arch";
  if (nirfCategory === "Law") return "Law/LLB";
  if (nirfCategory === "Dental") return "Dental/BDS";
  if (nirfCategory === "Agriculture") return "Agriculture/Allied";
  if (nirfCategory === "College") return "Arts/Science/Commerce (BA/BSc/BCom/BBA/BCA)";
  if (nirfCategory === "University" || nirfCategory === "Overall") return "Multi-disciplinary";
  // Fallbacks
  if (/IIT|NIT|IIIT|Institute of Technology/i.test(name)) return "Engineering";
  if (/IIM|Management/i.test(name)) return "Management/MBA";
  return "Multi-disciplinary";
}

// Helper: fetch with UA and simple retries
async function fetchWithUA(url, attempts = 3) {
  let lastErr;
  for (let i = 0; i < attempts; i++) {
    try {
      const res = await fetchFn(url, {
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
          Accept:
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
          "Accept-Language": "en-US,en;q=0.9",
          Connection: "keep-alive",
        },
      });
      if (!res.ok) throw new Error(`Fetch failed ${res.status} ${res.statusText}`);
      const text = await res.text();
      if (text && text.length > 0) return text; // accept any non-empty HTML
      throw new Error("Empty HTML");
    } catch (e) {
      lastErr = e;
      await new Promise((r) => setTimeout(r, 600 * (i + 1)));
    }
  }
  throw lastErr;
}

// Very light HTML table scraper for NIRF list pages
async function fetchNirfList({ cat, url }) {
  // First, try JSON/CSV endpoint
  const endpointRows = await tryFetchEndpoint({ cat, url });
  if (endpointRows && endpointRows.length) {
    console.log(`[NIRF] ${cat}: parsed ${endpointRows.length} rows via endpoint`);
    return endpointRows;
  }
  const html = await fetchWithUA(url);
  // Extract rows: these pages contain a table with Rank, Name, City, State, Score.
  // We'll do a permissive parse via regex (fast, robust enough for these pages).
  const rows = [];

  // 1) Header-based parsing: scan tables and map columns reliably
  try {
    const tables = html.match(/<table[\s\S]*?<\/table>/gi) || [];
    for (const table of tables) {
      const headerTr = (table.match(/<tr[^>]*>[\s\S]*?<\/tr>/gi) || []).find((tr) => /<th[^>]*>/i.test(tr));
      if (!headerTr) continue;
      const thRegex = /<th[^>]*>([\s\S]*?)<\/th>/gi;
      const headers = [];
      let th;
      while ((th = thRegex.exec(headerTr))) {
        const label = th[1].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim().toLowerCase();
        headers.push(label);
      }
      if (headers.length === 0) continue;
      const mapIndex = {};
      headers.forEach((h, i) => {
        const clean = h.replace(/[^a-z/ ]/g, "");
        if (/^rank\b|^overall\s*rank\b/.test(clean)) mapIndex.rank = i;
        else if (/(^|\s)(name of (the )?institute|institute name|name of institute|institution name|institute|institution|name|college name|university name)(\s|$)/.test(clean)) mapIndex.name = i;
        else if (/(^|\s)(city|city\/town|location)(\s|$)/.test(clean)) mapIndex.city = i;
        else if (/(^|\s)(state|state\/ut|province)(\s|$)/.test(clean)) mapIndex.state = i;
        else if (/(^|\s)(score|overall\s*score|nirf\s*score)(\s|$)/.test(clean)) mapIndex.score = i;
      });

      let haveAll = ["rank", "name", "city", "state", "score"].every((k) => Number.isInteger(mapIndex[k]));
      if (!haveAll) {
        // Fallback: infer likely columns by scanning first few body rows for alphabetic content
        const trBodies = (table.match(/<tr[^>]*>[\s\S]*?<\/tr>/gi) || []).filter((tr) => !/<th/i.test(tr));
        const sample = trBodies.slice(0, 6).map((row) => {
          const cells = Array.from(row.matchAll(/<td([^>]*)>([\s\S]*?)<\/td>/gi)).map((m) => {
            const attrs = m[1] || '';
            const inner = m[2] || '';
            const plain = inner.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
            const a = (inner.match(/<a[^>]*>([\s\S]*?)<\/a>/i) || [])[1] || '';
            const aText = a.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
            const dataOrder = (attrs.match(/data-(order|search)\s*=\s*(["'])(.*?)\2/i) || [])[3] || '';
            const titleAttr = (attrs.match(/title\s*=\s*(["'])(.*?)\1/i) || [])[2] || '';
            const best = [plain, dataOrder, aText, titleAttr].find((t) => /[A-Za-z]/.test(t)) || plain;
            return best;
          });
          return cells;
        });
        const maxCols = Math.max(0, ...sample.map((r) => r.length));
        const alphaScore = Array.from({ length: maxCols }, (_, i) => {
          const vals = sample.map((r) => (r[i] || ''));
          const alphaRatio = vals.filter((v) => /[A-Za-z]/.test(v)).length / Math.max(1, vals.length);
          const avgLen = vals.reduce((s, v) => s + v.length, 0) / Math.max(1, vals.length);
          return { i, alphaRatio, avgLen };
        });
        // Likely name column: highest avgLen among columns with alphaRatio >= 0.6
        const nameCand = alphaScore.filter((c) => c.alphaRatio >= 0.6).sort((a, b) => b.avgLen - a.avgLen)[0];
        if (nameCand) mapIndex.name = nameCand.i;
        // Likely state/city: other alpha-ish columns near name
        const others = alphaScore.filter((c) => c.i !== mapIndex.name && c.alphaRatio >= 0.4).sort((a, b) => b.avgLen - a.avgLen);
        if (!Number.isInteger(mapIndex.city) && others[0]) mapIndex.city = others[0].i;
        if (!Number.isInteger(mapIndex.state) && others[1]) mapIndex.state = others[1].i;
        // Rank: prefer column with mostly small integers
        if (!Number.isInteger(mapIndex.rank)) {
          const rankCand = alphaScore
            .map((c) => {
              const vals = sample.map((r) => (r[c.i] || ''));
              const intRatio = vals.filter((v) => /^\d{1,3}$/.test(v.replace(/[^\d]/g, ''))).length / Math.max(1, vals.length);
              return { i: c.i, intRatio };
            })
            .sort((a, b) => b.intRatio - a.intRatio)[0];
          if (rankCand && rankCand.intRatio >= 0.6) mapIndex.rank = rankCand.i;
        }
        // Score: prefer column with many floats
        if (!Number.isInteger(mapIndex.score)) {
          const scoreCand = alphaScore
            .map((c) => {
              const vals = sample.map((r) => (r[c.i] || ''));
              const floatRatio = vals.filter((v) => /^\d{1,3}(?:[.,]\d+)?$/.test(v.replace(/[^\d.,]/g, ''))).length / Math.max(1, vals.length);
              return { i: c.i, floatRatio };
            })
            .sort((a, b) => b.floatRatio - a.floatRatio)[0];
          if (scoreCand && scoreCand.floatRatio >= 0.6) mapIndex.score = scoreCand.i;
        }
        haveAll = ["rank", "name", "city", "state", "score"].every((k) => Number.isInteger(mapIndex[k]));
        console.log(`[NIRF][${cat}] inferred mapIndex:`, mapIndex);
        if (!haveAll) continue;
      }

      const trRegex = /<tr[^>]*>[\s\S]*?<\/tr>/gi;
      let tr;
      let added = 0;
      // debug: show header mapping once per table
      console.log(`[NIRF][${cat}] headers:`, headers);
      console.log(`[NIRF][${cat}] mapIndex:`, mapIndex);
      while ((tr = trRegex.exec(table))) {
        if (/<th/i.test(tr[0])) continue; // skip header rows
        // Collect tds with attributes
        const tds = [];
        const tdRegex = /<td([^>]*)>([\s\S]*?)<\/td>/gi;
        let td;
        while ((td = tdRegex.exec(tr[0]))) {
          const attrs = td[1] || "";
          const inner = td[2] || "";
          const text = inner.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
          // Try to grab anchor text, title and href if present
          let aText = undefined;
          let aTitle = undefined;
          let href = undefined;
          const aOpen = inner.match(/<a[^>]*>/i);
          if (aOpen) {
            const tag = aOpen[0];
            const titleAttr = tag.match(/title\s*=\s*(["'])(.*?)\1/i);
            if (titleAttr) aTitle = (titleAttr[2] || '').trim();
            const hrefAttr = tag.match(/href\s*=\s*(["'])(.*?)\1/i);
            if (hrefAttr) href = (hrefAttr[2] || '').trim();
          }
          const aMatch = inner.match(/<a[^>]*>([\s\S]*?)<\/a>/i);
          if (aMatch) {
            aText = aMatch[1].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
          }
          // Also check data-order / data-search on the td itself
          let dataOrder = undefined;
          const orderAttr = attrs.match(/data-(order|search)\s*=\s*(["'])(.*?)\2/i);
          if (orderAttr) dataOrder = (orderAttr[3] || '').trim();
          let title = undefined;
          const titleAttr = attrs.match(/title\s*=\s*(["'])(.*?)\1/i);
          if (titleAttr) title = (titleAttr[2] || '').trim();
          // Prefer meaningful text with letters
          const pick = (s) => (s && s.trim()) || '';
          const richText = /[A-Za-z]/.test(text)
            ? text
            : (/[A-Za-z]/.test(pick(dataOrder)) ? pick(dataOrder)
              : (/[A-Za-z]/.test(pick(aTitle)) ? pick(aTitle)
                : (/[A-Za-z]/.test(pick(aText)) ? pick(aText)
                  : (/[A-Za-z]/.test(pick(title)) ? pick(title) : text))));
          tds.push({ attrs, text: richText, rawText: text, aText, aTitle, title, href, dataOrder, innerHtml: inner });
        }
        if (tds.length === 0) continue;

        // Try mapping by data-label
        const byLabel = {};
        for (const cell of tds) {
          const m = cell.attrs.match(/data-label\s*=\s*(["'])(.*?)\1/i);
          if (m) {
            const label = (m[2] || "").toLowerCase();
            byLabel[label] = cell.text;
          }
        }
        const pickByLabel = (key) => {
          const candidates = {
            rank: [/^rank\b/, /overall\s*rank/],
            name: [/^(name of (the )?institute|institute name|name|college name|university name)\b/],
            city: [/^city\b/, /^city\/town\b/],
            state: [/^state\b/, /^state\/ut\b/],
            score: [/^score\b/, /overall\s*score/, /nirf\s*score/],
          }[key];
          for (const [label, val] of Object.entries(byLabel)) {
            if (candidates.some((re) => re.test(label))) return val;
          }
          return undefined;
        };

        let rRaw = pickByLabel('rank');
        let nRaw = pickByLabel('name');
        let cRaw = pickByLabel('city');
        let sRaw = pickByLabel('state');
        let scRaw = pickByLabel('score');

        // If labels missing, fall back to index mapping when lengths align
        if ([rRaw, nRaw, cRaw, sRaw, scRaw].some((v) => v === undefined)) {
          const flat = tds.map((c) => c.text);
          if (flat.length === headers.length) {
            rRaw = rRaw ?? flat[mapIndex.rank];
            nRaw = nRaw ?? flat[mapIndex.name];
            cRaw = cRaw ?? flat[mapIndex.city];
            sRaw = sRaw ?? flat[mapIndex.state];
            scRaw = scRaw ?? flat[mapIndex.score];
          } else {
            // Heuristic when there are extra metric columns
            const isInt = (x) => /^\d{1,3}$/.test(x.trim());
            const isFloat = (x) => /^\d{1,3}([.,]\d+)?$/.test(x.trim());
            // Find rank as last integer cell (<= 500)
            let rankIdx = -1;
            for (let i = flat.length - 1; i >= 0; i--) {
              const v = flat[i].replace(/[^\d]/g, "");
              if (v && isInt(v) && parseInt(v,10) <= 500) { rankIdx = i; break; }
            }
            // Score as the nearest float before rank
            let scoreIdx = -1;
            for (let i = rankIdx - 1; i >= 0; i--) {
              const v = flat[i].replace(/[^\d.]/g, "");
              if (v && isFloat(v)) { scoreIdx = i; break; }
            }
            // State and City before score
            let stateIdx = scoreIdx > 1 ? scoreIdx - 1 : -1;
            let cityIdx = stateIdx > 0 ? stateIdx - 1 : -1;
            // Name: earliest text-like cell before cityIdx
            let nameIdx = -1;
            for (let i = 0; i < flat.length && i < cityIdx; i++) {
              const t = flat[i];
              if (/[a-zA-Z]/.test(t) && !isFloat(t)) { nameIdx = i; break; }
            }
            if (rankIdx >= 0) rRaw = rRaw ?? flat[rankIdx];
            if (scoreIdx >= 0) scRaw = scRaw ?? flat[scoreIdx];
            if (stateIdx >= 0) sRaw = sRaw ?? flat[stateIdx];
            if (cityIdx >= 0) cRaw = cRaw ?? flat[cityIdx];
            if (nameIdx >= 0) nRaw = nRaw ?? flat[nameIdx];
          }
        }

        const r = parseInt(String(rRaw || "").replace(/[^\d]/g, ""), 10);
        const sc = parseFloat(String(scRaw || "").replace(/[^\d.]/g, ""));
        let n = String(nRaw || "").trim();
        let cty = String(cRaw || "").trim();
        let st = String(sRaw || "").trim();

        // Validate text fields
        const hasLetters = (s) => /[A-Za-z]/.test(s);
        if (!Number.isFinite(r) || !Number.isFinite(sc)) continue;

        // If name/city/state missing letters, try to follow a link in the row to fetch details
        if (!hasLetters(n) || !hasLetters(cty) || !hasLetters(st)) {
          const hrefMatch = (tr[0].match(/<a[^>]*href\s*=\s*(["'])(.*?)\1/i) || []);
          if (hrefMatch[2]) {
            try {
              const base = new NodeURL(url);
              const detailUrl = new NodeURL(hrefMatch[2], base).toString();
              // polite delay
              await new Promise((res) => setTimeout(res, 120));
              const detailHtml = await fetchWithUA(detailUrl);
              // Try extraction from <title> or first <h1>
              let title = (detailHtml.match(/<title[^>]*>([\s\S]*?)<\/title>/i) || [])[1] || '';
              title = title.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
              let h1 = (detailHtml.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i) || [])[1] || '';
              h1 = h1.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
              const candidateName = [h1, title].find((t) => /[A-Za-z]/.test(t)) || '';
              if (!hasLetters(n) && candidateName) n = candidateName;
              // Try to detect city/state tokens from detail page (very heuristic)
              const locMatch = detailHtml.match(/City\s*[:\-]\s*([A-Za-z .-]+).*?State\s*[:\-]\s*([A-Za-z .-]+)/is);
              if (locMatch) {
                if (!hasLetters(cty)) cty = locMatch[1].trim();
                if (!hasLetters(st)) st = locMatch[2].trim();
              }
            } catch {}
          }
        }

        if (!hasLetters(n) || !hasLetters(cty) || !hasLetters(st)) continue;

        rows.push({ rank: r, name: n, city: cty, state: st, score: sc, nirfCategory: cat });
        added++;
      }
      if (added === 1) {
        console.log(`[NIRF][${cat}] first row preview:`, { r, n, cty, st, sc });
      }
      if (added > 0) break; // we found the ranking table
      // If no rows added, dump first few body rows for debugging
      if (added === 0) {
        let count = 0;
        const bodyRows = (table.match(/<tr[^>]*>[\s\S]*?<\/tr>/gi) || []).filter((r) => !/<th/i.test(r));
        for (const row of bodyRows.slice(0, 3)) {
          const flat = Array.from(row.matchAll(/<td[^>]*>([\s\S]*?)<\/td>/gi)).map((m) => m[1].replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim());
          console.log(`[NIRF][${cat}] sample row ${++count}:`, flat);
        }
      }
    }
  } catch (_) {
    // fall through
  }

  // 2) Strict positional parsing (fallback)
  const strict = /<tr[^>]*>\s*<td[^>]*>(\d+)<\/td>[\s\S]*?<td[^>]*>(.*?)<\/td>[\s\S]*?<td[^>]*>(.*?)<\/td>\s*<td[^>]*>(.*?)<\/td>[\s\S]*?<td[^>]*>([\d.]+)<\/td>/gi;
  let m;
  if (rows.length === 0) {
    while ((m = strict.exec(html))) {
      const rank = parseInt(m[1], 10);
      const name = m[2].replace(/<[^>]+>/g, "").trim();
      const city = m[3].replace(/<[^>]+>/g, "").trim();
      const state = m[4].replace(/<[^>]+>/g, "").trim();
      const score = parseFloat(m[5]);
      if (!/[A-Za-z]/.test(name) || !/[A-Za-z]/.test(city) || !/[A-Za-z]/.test(state)) continue;
      rows.push({ rank, name, city, state, score, nirfCategory: cat });
    }
  }
  // 2b) Alternate order fallback: [Institute ID][Name][City][State][Score][Rank]
  if (rows.length === 0) {
    const alt = /<tr[^>]*>\s*<td[^>]*>\s*\S+\s*<\/td>\s*<td[^>]*>([\s\S]*?)<\/td>\s*<td[^>]*>([\s\S]*?)<\/td>\s*<td[^>]*>([\s\S]*?)<\/td>\s*<td[^>]*>([\d.]+)<\/td>\s*<td[^>]*>(\d+)<\/td>/gi;
    let a;
    while ((a = alt.exec(html))) {
      const name = a[1].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
      const city = a[2].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
      const state = a[3].replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
      const score = parseFloat(a[4].replace(/[^\d.]/g, ""));
      const rank = parseInt(a[5].replace(/[^\d]/g, ""), 10);
      if (!Number.isFinite(rank) || !Number.isFinite(score)) continue;
      if (!/[A-Za-z]/.test(name) || !/[A-Za-z]/.test(city) || !/[A-Za-z]/.test(state)) continue;
      rows.push({ rank, name, city, state, score, nirfCategory: cat });
    }
  }
  // Fallback: generic row parse with robust heuristics
  if (rows.length === 0) {
    const IN_STATES = [
      'andhra pradesh','arunachal pradesh','assam','bihar','chhattisgarh','goa','gujarat','haryana','himachal pradesh','jharkhand','karnataka','kerala','madhya pradesh','maharashtra','manipur','meghalaya','mizoram','nagaland','odisha','punjab','rajasthan','sikkim','tamil nadu','telangana','tripura','uttar pradesh','uttarakhand','west bengal','andaman and nicobar islands','chandigarh','dadra and nagar haveli and daman and diu','delhi','jammu and kashmir','ladakh','lakshadweep','puducherry'
    ];
    const norm = (s) => s.toLowerCase().replace(/\s+/g,' ').trim();
    const isInt = (x) => /^\d{1,3}$/.test(x.trim());
    const isFloat = (x) => /^\d{1,3}(?:[.,]\d+)?$/.test(x.trim());
    const trRegex = /<tr[\s\S]*?<\/tr>/gi;
    let tr;
    while ((tr = trRegex.exec(html))) {
      const tds = [];
      const tdRegex = /<td([^>]*)>([\s\S]*?)<\/td>/gi;
      let td;
      while ((td = tdRegex.exec(tr[0]))) {
        const attrs = td[1] || '';
        const inner = td[2] || '';
        const text = inner.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
        const aText = ((inner.match(/<a[^>]*>([\s\S]*?)<\/a>/i) || [])[1] || '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
        const dataOrder = (attrs.match(/data-(order|search)\s*=\s*(["'])(.*?)\2/i) || [])[3] || '';
        const titleAttr = (attrs.match(/title\s*=\s*(["'])(.*?)\1/i) || [])[2] || '';
        const best = [aText, dataOrder, titleAttr, text].find((t) => /[A-Za-z]/.test(t)) || text;
        if (best) tds.push(best);
      }
      if (tds.length < 3) continue;
      // Identify rank as the last small integer cell (<= 500)
      let rankIdx = -1;
      for (let i = tds.length - 1; i >= 0; i--) {
        const v = tds[i].replace(/[^\d]/g, '');
        if (v && isInt(v) && parseInt(v,10) <= 500) { rankIdx = i; break; }
      }
      // Identify score as the nearest float before rank (<= 100)
      let scoreIdx = -1;
      for (let i = rankIdx - 1; i >= 0; i--) {
        const v = tds[i].replace(/[^\d.,]/g, '');
        if (v && isFloat(v)) { const num = parseFloat(v.replace(',','.')); if (num <= 100) { scoreIdx = i; break; } }
      }
      // Identify state by matching against known state names, prefer cell right before score
      let stateIdx = -1;
      for (let i = Math.max(0, scoreIdx - 2); i < Math.min(tds.length, scoreIdx + 2); i++) {
        const t = norm(tds[i]);
        if (IN_STATES.includes(t)) { stateIdx = i; break; }
      }
      if (stateIdx < 0) {
        for (let i = 0; i < tds.length; i++) { if (IN_STATES.includes(norm(tds[i]))) { stateIdx = i; break; } }
      }
      // City: pick a text cell near state that has letters and is not a state
      let cityIdx = -1;
      if (stateIdx >= 0) {
        for (let i = stateIdx - 1; i >= 0; i--) { const t = norm(tds[i]); if (/[a-z]/.test(t) && !IN_STATES.includes(t)) { cityIdx = i; break; } }
      }
      // Name: the longest text cell before cityIdx that has letters and is not a state
      let nameIdx = -1, maxLen = -1;
      for (let i = 0; i < (cityIdx >= 0 ? cityIdx : tds.length); i++) {
        const t = tds[i]; const tn = norm(t);
        if (/[a-z]/.test(tn) && !IN_STATES.includes(tn)) { if (t.length > maxLen) { maxLen = t.length; nameIdx = i; } }
      }
      if (rankIdx >= 0 && scoreIdx >= 0 && stateIdx >= 0 && cityIdx >= 0 && nameIdx >= 0) {
        const rank = parseInt(tds[rankIdx].replace(/[^\d]/g, ''), 10);
        const score = parseFloat(tds[scoreIdx].replace(/[^\d.]/g, ''));
        const name = tds[nameIdx].trim();
        const city = tds[cityIdx].trim();
        const state = tds[stateIdx].trim();
        if (Number.isFinite(rank) && Number.isFinite(score) && /[A-Za-z]/.test(name) && /[A-Za-z]/.test(city) && /[A-Za-z]/.test(state)) {
          rows.push({ rank, name, city, state, score, nirfCategory: cat });
        }
      }
    }
  }
  console.log(`[NIRF] ${cat}: parsed ${rows.length} rows`);
  return rows;
}

// Guess website domains (best-effort). Real perfection requires institution pages.
// We keep it conservative: return null if unsure.
function guessWebsite(name) {
  const simple = name
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9 ]/g, "")
    .replace(/\s+/g, "");
  // a few known mappings
  const known = {
    indianinstituteoftechnologymadras: "https://www.iitm.ac.in",
    indianinstituteoftechnologydelhi: "https://www.iitd.ac.in",
    indianinstituteoftechnologybombay: "https://www.iitb.ac.in",
    indianinstituteoftechnologykanpur: "https://www.iitk.ac.in",
    indianinstituteoftechnologykharagpur: "https://www.iitkgp.ac.in",
    allindiainstituteofmedicalsciencesnewdelhi: "https://www.aiims.edu",
  };
  return known[simple] || null;
}

function toDoc(item) {
  const category = inferCategoryTag(item.nirfCategory, item.name);
  const shortName = (item.name.match(/\b(IIT|IIM|NIT|IIIT|AIIMS|BITS)\b/i)?.[0] || "")
    ? item.name.replace(/.*\b(IIT|IIM|NIT|IIIT|AIIMS|BITS)\b/i, (s) => s.toUpperCase())
    : item.name.split(" ").slice(0, 2).map((w) => w[0]).join("").toUpperCase().slice(0, 6);

  return {
    name: item.name,
    shortName,
    category, // our broad category for filtering
    tags: [item.nirfCategory, category],
    city: item.city,
    state: item.state,
    location: `${item.city}, ${item.state}`,
    country: "India",
    type:
      /University|Institute|National|Government|Indian Institute/i.test(item.name)
        ? "Government/Deemed/Institute of National Importance"
        : "Govt/Private (Mixed)",
    established: null, // can be enriched later
    nirfRank: item.rank,
    nirfScore: item.score,
    // Provide overallRank for compatibility with app ordering fallback
    overallRank: item.rank,
    fees: null, // can be enriched later
    coursesOffered: [], // deep course lists require institute pages
    placements: null, // official placement PDFs needed
    facilities: null,
    contact: {
      address: null,
      phone: null,
      email: null,
      website: guessWebsite(item.name),
      googleMapsUrl: null,
    },
    images: [],
    brochures: [],
    description: `${item.name} appears in NIRF ${item.nirfCategory} ranking ${item.rank}.`,
    lastUpdated: LAST_UPDATED,
    dataVersion: DATA_VERSION,
  };
}

(async () => {
  const all = [];
  let cats;
  try {
    cats = await discoverCategories(2024);
  } catch { cats = []; }
  if (!Array.isArray(cats) || cats.length === 0) {
    // Fallback: base URLs only
    cats = CATEGORY_NAMES.map((cat) => ({ cat, url: `https://www.nirfindia.org/Rankings/2024/${cat}Ranking.html` }));
  }
  for (const cfg of cats) {
    try {
      console.log(`[NIRF] Fetching: ${cfg.cat} -> ${cfg.url}`);
      const rows = await fetchNirfList(cfg);
      console.log(`[NIRF] Result: ${cfg.cat} -> ${rows.length} rows`);
      for (const r of rows) all.push(r);
    } catch (e) {
      console.error("Failed:", cfg, e.message);
    }
  }

  // De-duplicate by name + state, pick best (lowest) rank per name across categories
  const byKey = new Map();
  for (const r of all) {
    const key = `${r.name}::${r.state}`;
    if (!byKey.has(key) || r.rank < byKey.get(key).rank) byKey.set(key, r);
  }
  let dedup = Array.from(byKey.values());

  // Sort by NIRF rank within their source category; then Overall/Engineering first
  const pref = [
    "Overall",
    "University",
    "Engineering",
    "Medical",
    "Management",
    "College",
    "Pharmacy",
    "Architecture",
    "Law",
    "Dental",
    "Agriculture",
  ];
  dedup.sort((a, b) => {
    const ca = pref.indexOf(a.nirfCategory),
      cb = pref.indexOf(b.nirfCategory);
    if (ca !== cb) return ca - cb;
    return a.rank - b.rank;
  });

  // Keep top ~220 to ensure 200+ coverage across streams
  if (dedup.length > 220) dedup = dedup.slice(0, 220);

  const docs = dedup.map(toDoc);
  const out = {
    dataVersion: DATA_VERSION,
    lastUpdated: LAST_UPDATED,
    total: docs.length,
    colleges: docs,
  };

  fs.writeFileSync(path.join(process.cwd(), "colleges.json"), JSON.stringify(out, null, 2));
  console.log(`Wrote colleges.json with ${docs.length} colleges`);
})();
