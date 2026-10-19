"""Exercise launch decisions with a fake adb; never touches a device."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]


class AndroidLaunchTests(unittest.TestCase):
    def launch_with_focus(self, focus):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            adb = base / 'adb'
            adb.write_text('''#!/usr/bin/env bash
case "$*" in
  *resolve-activity*) echo 'com.honestfern.currency_converter/.MainActivity';;
  *'dumpsys window'*) printf '  mCurrentFocus=Window{%s}\\n' "$FAKE_FOCUS";;
  *'lastanr'*) echo 'No historical ANR';;
esac
''')
            adb.chmod(0o755)
            sleep = base / 'sleep'
            sleep.write_text('#!/usr/bin/env bash\nexit 0\n')
            sleep.chmod(0o755)
            diagnostics = base / 'diagnostics'
            env = dict(os.environ, ADB_BIN=str(adb), ANDROID_SERIAL='fake-device',
                       FAKE_FOCUS=focus, ANDROID_DIAGNOSTIC_DIR=str(diagnostics),
                       PATH=f'{base}:{os.environ["PATH"]}')
            result = subprocess.run(['bash', str(ROOT / '.devtools/android_launch.sh')],
                                    env=env, capture_output=True, text=True, timeout=15)
            return result, diagnostics.exists()

    def test_focused_app_succeeds(self):
        result, diagnosed = self.launch_with_focus(
            'com.honestfern.currency_converter/com.honestfern.currency_converter.MainActivity')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('attempt 1', result.stdout)
        self.assertFalse(diagnosed)

    def test_launcher_anr_fails_and_collects_evidence(self):
        result, diagnosed = self.launch_with_focus(
            'Application Not Responding: com.google.android.apps.nexuslauncher')
        self.assertEqual(result.returncode, 1)
        self.assertTrue(diagnosed)
        self.assertIn('not confirmed foreground', result.stderr)

    def test_own_app_anr_is_not_success(self):
        result, diagnosed = self.launch_with_focus(
            'Application Not Responding: com.honestfern.currency_converter')
        self.assertEqual(result.returncode, 1)
        self.assertTrue(diagnosed)
