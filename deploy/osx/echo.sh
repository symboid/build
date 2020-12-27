
function EchoIndent
{
	IndentString=$1
	echo -n "$IndentString"
	echo -n " | "
}

function EchoSep
{
	echo -n "______"
	for i in {1..100}; do
		echo -n "_"
	done
	echo "_"
	EchoIndent "    "
	echo " "
}

EchoHeaderWidth=24

function EchoLine
{
	LineHeader="$1"
	LineValue="$2"
	
	EchoIndent "    "
	echo -n "$LineHeader"
	
	EchoPos=${#1}
	while [[ EchoPos -lt $EchoHeaderWidth ]]; do
		echo -n " "
		eval EchoPos=$EchoPos+1
	done
	
	echo -n " : "
	echo "$LineValue"
}

function EchoVar
{
    VarName="$1"
    VarValue="$2"

    EchoLine "$VarName" "$VarValue"
}

function EchoMsg
{
	Indent="$1"
	Msg="$2"
	EchoIndent "$Indent"
	echo "$Msg"
}

function EchoInfo
{
	EchoMsg "    " "$1"
}

function EchoError
{
	EchoMsg "[EE]" "$1"
}
