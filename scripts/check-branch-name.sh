#!/usr/bin/env sh
# Kiem tra ten nhanh Git theo quy uoc cua du an.
# Dung: sh scripts/check-branch-name.sh [ten-nhanh]
# Khong truyen tham so -> lay nhanh hien tai.

BRANCH="${1:-$(git symbolic-ref --short HEAD 2>/dev/null)}"

# main: nhanh production, chi nhan PR tu dev
# dev: nhanh tich hop, nhan PR tu cac nhanh <type>/*
# release/x.y.z: nhanh on dinh phat hanh, cat tu dev
# <type>/<ten-ngan>: type giong Conventional Commits, ten lowercase + so/gach
# dependabot/*, renovate/*: bot tu dong
PATTERN='^(main|dev|release/[0-9]+\.[0-9]+\.[0-9]+|(feat|fix|refactor|perf|test|docs|chore|build|ci|revert)/[a-z0-9][a-z0-9._-]*|(dependabot|renovate)/.*)$'

if [ -z "$BRANCH" ]; then
    echo "Khong xac dinh duoc ten nhanh (dang detached HEAD?)."
    exit 1
fi

if printf '%s' "$BRANCH" | grep -Eq "$PATTERN"; then
    echo "Ten nhanh hop le: $BRANCH"
    exit 0
fi

echo "Ten nhanh khong hop le: $BRANCH"
echo "Quy uoc:"
echo "  main"
echo "  dev"
echo "  release/<major>.<minor>.<patch>"
echo "  <type>/<ten-ngan>   (feat, fix, refactor, perf, test, docs, chore, build, ci, revert)"
echo "Vi du: feat/player-double-jump, fix/slime-collision, docs/update-readme"
exit 1
