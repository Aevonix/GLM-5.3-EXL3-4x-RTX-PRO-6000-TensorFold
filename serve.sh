#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
: "${PROFILE:=$root/profiles/production.env}"
if [[ ! -f $PROFILE ]]; then
 echo "Profile is not available: $PROFILE. Qualification may still be in progress." >&2
 exit 2
fi
while IFS='=' read -r key value; do
 [[ -z $key || $key == \#* ]] && continue
 [[ $key =~ ^[A-Z][A-Z0-9_]*$ && -n $value ]] || { echo 'Invalid profile entry' >&2; exit 2; }
 if [[ -z ${!key+x} ]]; then export "$key=$value"; fi
done < "$PROFILE"
if [[ ${CP:-1} == 1 && ${PARALLEL:-1} -gt 1 ]]; then
 export TF_GLM_CP_MULTI=1 TF_GLM_MULTI_VERIFY=segments TF_GLM_MULTI_PREFILL=0
 export TF_GLM_CP_PAGED=${TF_GLM_CP_PAGED:-1} TF_GLM_CP_PAGED_KERNELS=1
 export TF_GLM_CP_MULTI_GRAPHS=${TF_GLM_CP_MULTI_GRAPHS:-1} TF_GLM_CACHE_GIB=0
else
 export TF_GLM_CP_POOL_TOKENS=0
 unset TF_GLM_DSPARK_POLICY TF_GLM_DSPARK_MOST TF_GLM_DSPARK_BLOCK
 if [[ ${CP:-1} == 1 && ${DRAFTER:-dspark} == dspark ]]; then
  export TF_GLM_DSPARK_POLICY=cost TF_GLM_DSPARK_MOST=8 TF_GLM_DSPARK_BLOCK=8
 fi
fi
if [[ ${DRAFTER:-dspark} == dflash2 ]]; then
 [[ ${PARALLEL:-1} == 1 ]] || { echo 'This recipe supports DFlash2 only with PARALLEL=1.' >&2; exit 2; }
 export COPY=0 COPY_HYBRID=0
fi
exec bash "$root/scripts/start-integrated.sh" "$@"
