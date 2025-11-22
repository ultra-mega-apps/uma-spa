#!/bin/bash

json_escape() {
	local raw_value="$1"

	local escaped_value
	escaped_value="${raw_value//\\/\\\\}"
	escaped_value="${escaped_value//\"/\\\"}"
	escaped_value="${escaped_value//$'\n'/\\n}"
	escaped_value="${escaped_value//$'\r'/\\r}"
	escaped_value="${escaped_value//$'\t'/\\t}"
	escaped_value="${escaped_value//$'\b'/\\b}"
	escaped_value="${escaped_value//$'\f'/\\f}"

	printf '%s' "${escaped_value}"
}

build_json_from_env() {
	local names_list="$1"

	local first_pair=1

	printf '{'

	local newline_separated
	newline_separated=$(echo "${names_list}" | tr ',' '\n')

	for variable_name in ${newline_separated}; do

		local variable_value="${!variable_name}"
		local escaped_value
		escaped_value=$(json_escape "${variable_value}")

		if [[ ${first_pair} -eq 0 ]]; then
			printf ', '
		fi

		printf '"%s":"%s"' "${variable_name}" "${escaped_value}"

		first_pair=0
	done

	printf '}'
}

if [[ -n "${CONFIG_VARS}" ]]; then

	JSON=$(build_json_from_env "${CONFIG_VARS}")

	echo " ==> Writing ${CONFIG_FILE_PATH}/config.js with ${JSON}"

	echo "window.__env = ${JSON}" >"${CONFIG_FILE_PATH}/config.js"
fi

exec "$@"
