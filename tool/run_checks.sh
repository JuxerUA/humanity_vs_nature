#!/usr/bin/env bash
set -e

exit_code=0

if command -v dart >/dev/null 2>&1; then
  echo 'Running dart analyze'
  if ! dart analyze; then
    exit_code=1
  fi
else
  echo 'Dart is not installed; skipping analysis.'
fi

if command -v flutter >/dev/null 2>&1; then
  echo 'Running flutter test'
  if ! flutter test; then
    exit_code=1
  fi
else
  echo 'Flutter is not installed; skipping tests.'
fi

exit $exit_code
