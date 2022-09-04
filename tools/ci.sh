#!/bin/bash

# fail on error
set -e

# enable shell tracing
set -x

MD5SUM=$(which md5sum || true)
if [ -z "$MD5SUM" ]; then MD5SUM="$(md5 -r)"; fi

test_formula_hash ()
{
  local -r EXPECTED_SUM="$1"
  shift 1
  local -r TEST_PARAMS="$*"
  
  # build modgen
  make clean
  make
  
  # generate CNF to be tested
  ./modgen $TEST_PARAMS > test.cnf
  HASHSUM=$($MD5SUM test.cnf | awk '{print $1}')

  if [ -z "$HASHSUM" ]; then
    echo "error: failed to compute hashsum"
    return 1
  fi


  if [ "$EXPECTED_SUM" != "$HASHSUM" ]; then
    echo "error: detected unexpected hash for formula with parameters $TEST_PARAM"
    echo "info: detected hash: $HASHSUM expected hash: $EXPECTED_SUM"
    return 2
  fi
  
  return 0
}


# run all tests
declare -i OVERALL_STATUS=0
test_formula_hash 0dc0f0402648bc7f2f6a5ec6973e6d7b -s 4900 -n 1000 -m 3000 || OVERALL_STATUS=$?
test_formula_hash 67159456029751365efc2451c9c852f2 -s 2400 -n 15000 -m 72500 || OVERALL_STATUS=$?
test_formula_hash 7a31a059e2f4986163daae16b56b6bf9 -s 4900 -n 1000000 -m 3000000 || OVERALL_STATUS=$?
test_formula_hash 20a7965a2b73dcfa4a40d14c34514a7f -s 3900 -n 10000 -m 38000 || OVERALL_STATUS=$?

# fail in case at least one test failed
echo "Found overall status: $OVERALL_STATUS"
exit $OVERALL_STATUS
