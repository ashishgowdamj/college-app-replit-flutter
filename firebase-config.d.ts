import { Firestore } from 'firebase-admin/firestore';
import { Auth } from 'firebase-admin/auth';
import { Storage } from 'firebase-admin/storage';
import { App } from 'firebase-admin/app';

export interface FirebaseConfig {
  admin: App;
  db: Firestore;
  auth: Auth;
  storage: Storage;
}

declare const config: FirebaseConfig;
export const { admin, db, auth, storage } = config;

