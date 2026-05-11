#!/usr/bin/env node
// Generates seed data JSON matching sample_seed_data.dart algorithm
// Run from project root: node .devtools/generate_seed_json.js
//
// NOTE: This file is a skeleton. Copy from your app's sample_seed_data.dart
// and implement the matching algorithm here. The output should match the
// shape of generateMockSharedPreferencesValues().

const fs = require('fs');

const SEED_PROFILE = {
  onboardingComplete: true,
};

function buildDayLog(date, dayIndex, daysAgo, totalDays) {
  return {
    dateKey: formatDate(date),
  };
}

function formatDate(date) {
  const year = date.getFullYear().toString().padStart(4, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Main execution
const DAYS = 90;
const today = new Date();
today.setHours(0, 0, 0, 0);

const logs = {};
for (let daysAgo = DAYS - 1; daysAgo >= 0; daysAgo--) {
  const date = new Date(today);
  date.setDate(date.getDate() - daysAgo);
  const dayIndex = DAYS - 1 - daysAgo;
  const log = buildDayLog(date, dayIndex, daysAgo, DAYS);
  logs[log.dateKey] = log;
}

const result = {
  profile: SEED_PROFILE,
  logs: logs,
  templates: [],
};

console.log(JSON.stringify(result, null, 2));
