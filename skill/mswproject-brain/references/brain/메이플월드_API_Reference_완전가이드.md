# 메이플스토리 월드 API Reference 완전 가이드

> 이 문서는 [API Reference 가이드라인](https://maplestoryworlds-creators.nexon.com/ko/apiReference/How-to-use-API-Reference) 페이지의 내용을 기반으로 작성되었습니다.

---

## 1. API 카테고리 개요

메이플스토리 월드 API는 다음 8개의 주요 카테고리로 구성됩니다.

| 카테고리 | 설명 |
|---------|------|
| **Components** | 월드 제작 시 엔티티에 추가해 사용하는 기능 단위. 프로퍼티와 함수를 갖습니다. |
| **Events** | 월드의 다양한 API에서 발생하는 이벤트. 프로퍼티와 발생 공간 정보를 제공합니다. |
| **Services** | 시스템 제작과 관련된 핵심 기능 제공. 프로퍼티와 함수를 갖습니다. |
| **Logics** | 월드 제작에 필요한 게임 로직. 프로퍼티와 함수를 갖습니다. |
| **Misc** | 월드에서만 사용하는 고유 타입. 프로퍼티, 생성자, 함수를 갖습니다. |
| **Enums** | 서로 연결된 값의 집합. 프로퍼티, 생성자, 함수를 갖습니다. |
| **Lua** | Lua 5.3 기반 스크립팅 언어. 일부는 표준과 상이할 수 있습니다. |
| **Log Messages** | 로그 메시지 종류 (Info, Warning, Error). |

---

## 2. 기본 스크립팅 언어: Lua 5.3

메이플스토리 월드는 **Lua 5.3** 버전을 기본 스크립트 언어로 사용합니다.

- 공식 문서: [Lua 5.3 Manual](https://www.lua.org/manual/5.3/)
- 일부 기능은 Lua 5.3 표준과 **상이할 수 있음** (MSW 전용 수정)

---

## 3. API 문서 형식 이해

### 3.1 API 페이지 구성

각 API 페이지는 다음 구조로 구성됩니다:

1. **API 이름**: API의 명칭
2. **API 설명**: 해당 API의 전체적인 특성 설명
3. **Properties**: API의 프로퍼티 상세 정보
   - 상속받은 프로퍼티는 `inherited from XXX` 아래에 표시
4. **Functions**: API의 함수 상세 설명
   - 상속받은 함수는 `inherited from XXX` 아래에 표시
5. **Examples**: API 활용 예제 코드

### 3.2 API 구문 형식

```
타입 이름(인자타입 인자이름)
```

| 요소 | 설명 |
|------|------|
| **타입** | 프로퍼티/함수/이벤트의 리턴 타입. 관련 문서로 연결될 수 있음 |
| **이름** | API의 프로퍼티/함수/이벤트 이름 |
| **인자 타입** | 인자가 사용하는 특정 타입 |
| **인자 이름** | API 사용에 필요한 파라미터 |

### 3.3 특수 인자 표기법

| 표기 | 의미 | 예시 |
|------|------|------|
| `=nil` | 생략 가능한 파라미터 | `CollisionGroup=nil` |
| `...` | 가변 파라미터 | `any... args` |

---

## 4. 배지(Badge) 색상 가이드

API 문서에서 사용되는 배지들의 의미를 설명합니다.

### 4.1 동기화 정보 배지

| 배지 | 의미 |
|------|------|
| **Sync** (청록색) | 서버에서 클라이언트로 값이 자동 동기화됨 |

### 4.2 실행 공간 제어 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **ReadOnly** | 주황색 | 읽기 전용, 덮어쓸 수 없음 |
| **ControlOnly** | 토마토색 | 조작 권한을 가진 환경 전용 함수 |
| **MakerOnly** | 살몬색 | 메이커에서만 사용 가능 |
| **ReleaseOnly** | 빨간색 | 출시된 월드에서만 사용 가능 |
| **ServerOnly** | 자홍색 | 서버 전용 함수 (서버에서만 호출) |
| **ClientOnly** | 주황빨강 | 클라이언트 전용 함수 (클라이언트에서만 호출) |
| **Server** | 연분홍색 | 서버에서 실행. 클라이언트 호출 시 서버로 요청 |
| **Client** | 보라색 | 클라이언트에서 실행. 서버 호출 시 클라이언트들에게 전달 |

### 4.3 프로퍼티 관련 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **HideFromInspector** | 보라색 | 메이커 프로퍼티 창에 노출 안됨. 스크립트 에디터에서만 접근 |

### 4.4 함수 관련 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **Yield** | 갈색 | 수행 동안 스크립트 실행 중단 |
| **Static** | 장밋빛갈색 | 전역으로 접근 가능 |

### 4.5 스크립트 관련 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **ScriptOverridable** | 파란색 | 재정의(오버라이드) 가능한 함수 |

### 4.6 타입 관련 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **Abstract** | 카키색 | 자체적으로 Component 생성 불가능한 추상화된 API |

### 4.7 API 상태 관련 배지

| 배지 | 색상 | 의미 |
|------|------|------|
| **Deprecated** | 회색 | 더 이상 사용하지 않는 API |
| **Preview** | 슬레이트그레이 | 크리에이터에게 선공개된 API. 정식 배포 시 변경될 수 있음 |

### 4.8 이벤트 공간 배지

| 배지 | 의미 |
|------|------|
| **Space: Server** | 서버에서 이벤트 발생 |
| **Space: Client** | 클라이언트에서 이벤트 발생 |
| **Space: Editor** | 에디터에서 이벤트 발생 |
| **Space: All** | 서버와 클라이언트 모두에서 이벤트 발생 |

---

## 5. 로그 메시지 시스템

로그 메시지는 접두사로 레벨을 구분합니다.

| 레벨 | 접두사 | 설명 |
|------|--------|------|
| **Info Level** | `LIA` | 정보성 메시지 |
| **Warning Level** | `LWA` | 동작은 하지만 문제가 있는 경우. 권장 형태가 아니거나 의도와 다르게 동작할 수 있음 |
| **Error Level** | `LEA` | 정상 동작 불가능하거나 의도대로 동작하지 않아 결과를 얻을 수 없는 경우 |

---

## 6. 코딩 핵심 규칙 요약

### 6.1 Server/Client 구분

메이플스토리 월드는 **멀티플레이어 환경**입니다. 따라서:

- **ServerOnly** 함수는 서버에서만 호출 가능
- **ClientOnly** 함수는 클라이언트에서만 호출 가능
- **Server** 배지 함수: 클라이언트에서 호출하면 서버로 요청 전달
- **Client** 배지 함수: 서버에서 호출하면 모든 클라이언트에게 전달

### 6.2 동기화 (Sync)

- **Sync** 배지가 붙은 프로퍼티는 서버에서 변경 시 클라이언트에 자동 반영
- 동기화되지 않는 프로퍼티는 직접 동기화 로직 구현 필요

### 6.3 Yield 함수 사용 시 주의

- **Yield** 배지 함수는 실행 중 스크립트를 **일시 중단**함
- 비동기 처리가 필요한 경우 사용

### 6.4 생략 가능한 파라미터

- `파라미터명=nil` 형태로 표기된 인자는 생략 가능
- 생략 시 기본값(nil 또는 정의된 값) 적용

---

## 7. 참고 링크

- [API Reference 가이드라인](https://maplestoryworlds-creators.nexon.com/ko/apiReference/How-to-use-API-Reference)
- [Components](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Components)
- [Events](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Events)
- [Services](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Services)
- [Logics](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Logics)
- [Misc](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Misc)
- [Enums](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Enums)
- [Lua](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua)
- [Log Messages](https://maplestoryworlds-creators.nexon.com/ko/apiReference/LogMessages)
- [Lua 5.3 공식 매뉴얼](https://www.lua.org/manual/5.3/)
