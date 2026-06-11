# :iphone: Paleto 팔레토
<img width="256" height="256" alt="LOGO_PALETO" src="https://github.com/user-attachments/assets/204b440c-df09-4b0e-9c6f-2de55fa81e68" />

> AVFoundation 기반의 커스텀 카메라와 Core Image의 색상 분석 및 이미지 편집 기능을 활용해 일상 속 색을 탐색하여 미션을 클리어하는 미션형 필터 카메라 앱

## 📆 Duration
- 전체 기간: `2026.05.06 - 2026.06.12`
- 개발 기간: `2026.05.28 - 2026.06.10`


## :fireworks: Screenshots

Attach photos if you are available

## :framed_picture: Demo (optional)

Attach videos if you are available


## :pushpin: Features
**🎨 색상 미션 & 빙고**
- **5가지 테마 색상:** Red·Orange·Green·Blue·Purple 색상별 잠금 해제 시스템
- **랜덤 빙고 미션:** 색상마다 8칸의 무작위 미션 빙고판 생성
- **데이터 영구 저장:** 유저의 미션 진행도 및 성공 여부 로컬 저장

**📷 모듈형 카메라 (Common Base)**
- **공통 기능:** 실시간 프리뷰 · 전/후면 전환 · 줌(0.5x / 1x / 2x) · 그리드 시스템 · 권한 안내
- **미션 카메라 모드:** - 미션 가이드 오버레이 제공 및 촬영 후 성공/실패 연출
  - **Core Image/HSV 기반 색상 판정:** Hue 밴드 보정과 픽셀 카운트 알고리즘으로 미세한 색 영역까지 정확하게 인식
- **필터 카메라 모드:** - **LUT(ColorCube) 기반:** 실시간 색상 필터 캐러셀 제공 및 강도(슬라이더) 조절
  - 아날로그 감성의 그레인(Grain) 효과 및 플래시 기능 지원

**✂️ 미션 편집기**
- 미션 타입별 맞춤형 실시간 편집 및 이미지 프로세싱 지원
- 기본 카메라 · 명도 조절 · 채도 조절 · 4:3 크롭(Crop) · 컬러피커(Color Picker)

**🏆 완료 및 리워드**
- **빙고 콜라주:** 8개 미션 완료 시 3×3 형태의 빙고 인증샷 콜라주 자동 생성
- **잠금 해제 시스템:** 미션 완료 보상으로 새로운 커스텀 색상 필터 제공
- **공유 및 저장:** 완성된 콜라주 이미지 로컬 저장 및 시스템 공유 지원


## :sparkles: Skills & Tech Stack

### Tech Stack
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)


![SwiftUI](https://img.shields.io/badge/SwiftUI-F05138?style=flat-square&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-F05138?style=flat-square&logo=swift&logoColor=white)


![AVFoundation](https://img.shields.io/badge/AVFoundation-%23000000?style=flat-square&logo=apple&logoColor=white)
![Core Image](https://img.shields.io/badge/Core_Image-%23000000?style=flat-square&logo=apple&logoColor=white)
![PhotoKit](https://img.shields.io/badge/PhotoKit-%23000000?style=flat-square&logo=apple&logoColor=white)


### Tools
![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?style=for-the-badge&logo=figma&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)


## :people_hugging: Authors

<table>
  <tr align="center">
    <td width="200"><b>노아 Noah</b></td>
    <td width="200"><b>이피 Eepy</b></td>
    <td width="200"><b>하르딘 Jardín</b></td>
    <td width="200"><b>젠 Zen</b></td>
    <td width="200"><b>크리스탈 Crystal</b></td>
    <td width="200"><b>그레이스 Grace</b></td>
  </tr>
  <tr align="center">
    <td><img src="https://github.com/user-attachments/assets/ec790596-9b59-4ce1-aaf5-ae655e8947ea" width="150"></td>
    <td><img src="https://github.com/user-attachments/assets/ae203c97-2c27-49bc-abcc-73a895316a45" width="150"></td>
    <td><img src="https://github.com/user-attachments/assets/6c7735bb-ad59-45cd-82aa-9d13045d034d" width="150"></td>
    <td><img src="https://github.com/user-attachments/assets/dff40d1b-cdc8-452e-a188-94a01c9087f9" width="150"></td>
    <td><img src="https://github.com/user-attachments/assets/ce424c86-162c-4d0d-8fa2-d1a389f3ff3f" width="150"></td>
    <td><img src="https://github.com/user-attachments/assets/b6561c77-3737-4166-aa63-ebee60bde07b" width="150"></td>
  </tr>
  <tr align="center">
    <td>iOS Developer</td>
    <td>iOS Developer</td>
    <td>iOS Developer</td>
    <td>UX/UI Designer</td>
    <td>UX/UI Designer</td>
    <td>UX/UI Designer</td>
  </tr>
  <tr align="center">
    <td><a href="https://github.com/noah-jhlee">@noah-jhlee</a></td>
    <td><a href="https://github.com/yoonjin9150-blip">@yoonjin9150-blip</a></td>
    <td><a href="https://github.com/frutacruda">@frutacruda</a></td>
    <td><a href="https://github.com/kiim672">@kiim672</a></td>
    <td><a href="https://github.com/crystaltheclear">@crystaltheclear</a></td>
    <td><a href="https://github.com/glace0x">@glace0x</a></td>
  </tr>
</table>


## 🧱 Directory
Architecture : MVVM 


```
📦 C3_App
┣ 📂 Components
┣ 📂 Extensions
┣ 📂 Models
┣ 📂 ViewModels
┗ 📂 Views
```

## ✅ How to Test

1. 이 저장소를 클론합니다.
```bash
git clone https://github.com/yourteam/project.git
```
2. `Xcode`로 `.xcodeproj` 또는 `.xcworkspace` 열기
3. 시뮬레이터 환경 설정: iPhone 15 / iOS 17
4. `Cmd + R`로 실행 / `Cmd + U`로 테스트 실행

