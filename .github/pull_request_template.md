## Mo ta

<!-- Tom tat thay doi va ly do. Link issue neu co: Closes #123 -->

## Loai thay doi

- [ ] `feat` — tinh nang moi
- [ ] `fix` — sua loi
- [ ] `refactor` / `perf` — khong doi hanh vi
- [ ] `docs` / `chore` / `build` / `ci`

## Checklist

- [ ] Nhanh dat ten dung quy uoc (`feat/...`, `fix/...`, ...), khong push truc tiep len `main`/`dev`
- [ ] PR nham dung dich: `<type>/*` → `dev`; chi `dev` duoc PR vao `main`
- [ ] Da rebase len `dev` moi nhat, khong co merge commit (`git fetch origin && git rebase origin/dev`)
- [ ] Commit message dung Conventional Commits
- [ ] PR title dung Conventional Commits (`<type>(scope): mo ta`)
- [ ] Da chay `npm run check:format`, `npm run check:csharp`, `npm run check:unity`
- [ ] Project mo duoc, Console khong co loi compile
- [ ] Da chay Test Runner (EditMode; PlayMode neu lien quan gameplay)
- [ ] Khong commit `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/`
- [ ] Asset moi co `.meta`, dat dung folder va prefix
- [ ] Cap nhat `docs/` neu thay doi kien truc, tech stack hoac quy uoc

## Cach test

<!-- Cac buoc de reviewer kiem tra: scene nao, bam gi, ket qua mong doi -->
