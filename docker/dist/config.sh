#!/bin/bash
REPOURL=${REPOURL:-https://github.com/seth0r/ffp-pdmsrv}

cp "${DISTDIR}/runinside.sh" "${TARGETDIR}/root/runinside.sh"
chmod +x "${TARGETDIR}/root/runinside.sh"

git clone $REPOURL "${TARGETDIR}/root/repo"
