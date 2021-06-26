#!/usr/bin/env bash

# copied from rules_k8s/k8s/apply.sh.tpl, slightly modified.
set -euo pipefail

function guess_runfiles() {
    pushd ${BASH_SOURCE[0]}.runfiles > /dev/null 2>&1
    pwd
    popd > /dev/null 2>&1
}

# this is different to the original apply.sh.tpl. We use the "RUNFILES_DIR", which
# is set by multirun, if it is called from multirun. If not, we use the same code
# as rules_k8s to guess the runfiles directory.
RUNFILES="${RUNFILES_DIR:-$(guess_runfiles)}"

%{tf_binary} -chdir=%{module_dir} init
%{tf_binary} -chdir=%{module_dir} %{command} %{args}
