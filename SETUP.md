# 실시간 공유 예약 캘린더 설정

이 사이트는 Supabase를 연결하면 여러 컴퓨터에서 하나의 예약 정보를 실시간 공유합니다. 사이트 입장 시 공용 비밀번호가 필요합니다.

## 1. Supabase 프로젝트 만들기

1. [Supabase](https://supabase.com/dashboard)에서 새 프로젝트를 만듭니다.
2. 프로젝트의 **SQL Editor**를 열고 `supabase-schema.sql` 전체를 붙여 넣어 실행합니다.
## 2. 사이트 연결하기

1. **Project Settings → API**를 엽니다.
2. Project URL과 **Publishable key**(또는 legacy anon key)를 복사합니다.
3. `supabase-config.js`에서 빈 문자열을 각각 붙여 넣습니다.

```js
window.SUPABASE_CONFIG = {
  url: "https://내-프로젝트.supabase.co",
  publishableKey: "sb_publishable_..."
};
```

`service_role` 키는 절대 웹사이트에 넣지 마세요. 이 키는 모든 데이터 보안을 우회합니다.

## 3. GitHub Pages로 배포·공유하기

1. GitHub에서 `equipment-reservation`이라는 **Public** 저장소를 만듭니다.
2. 이 폴더 안의 모든 파일과 숨김 폴더 `.github`를 저장소 최상위에 업로드합니다.
3. 저장소의 **Settings → Pages**에서 Source를 **GitHub Actions**로 선택합니다.
4. `Actions` 탭의 `Deploy reservation calendar to GitHub Pages` 작업이 완료되면, Pages 화면에 표시된 URL을 팀원에게 공유합니다.

이후에는 파일을 수정하여 `main` 브랜치에 올리기만 하면 사이트가 자동으로 새 버전으로 배포됩니다. 모든 사람이 동일한 GitHub Pages URL로 접속해야 합니다.

## 동작 방식과 유의사항

- 장비와 예약은 Supabase 데이터베이스에 저장됩니다.
- 다른 사람이 추가·수정·삭제하면 페이지를 새로고침하지 않아도 캘린더가 갱신됩니다.
- 예약 저장은 DB 함수가 같은 장비·날짜의 시간을 다시 검사합니다. 따라서 두 사람이 거의 동시에 같은 시간대를 등록하려 해도 한 건만 저장됩니다.
- 공용 비밀번호는 `1234`이며, 한 번 입력하면 같은 브라우저에서는 자동으로 열립니다.
- 이 방식은 링크를 아는 사람에게 비밀번호를 묻는 간단한 장벽입니다. 정적 웹사이트에서는 비밀번호 자체를 완전히 숨길 수 없으므로, 민감한 정보 저장에는 적합하지 않습니다.
