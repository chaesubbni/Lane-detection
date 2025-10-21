### 프로젝트 개요 
- Canny Edge Algorithm 과 Hough Transform 을 사용해 주행 동영상에서 차선을 인식했습니다.

- 
- <img width="550" height="428" alt="image" src="https://github.com/user-attachments/assets/784ba521-fdd6-40a8-b0c4-d0d97cd9f6f8" />

- <img width="550" height="441" alt="image" src="https://github.com/user-attachments/assets/6a83a6ef-3e48-45c1-a592-a7a2db8e9ed7" />

- <img width="562" height="363" alt="image" src="https://github.com/user-attachments/assets/ded84668-ece3-46c6-8c2c-d821ed0fb718" />


### Canny Edge
- Canny Edge는 윤곽선 검출 알고리즘입니다.
- 일단, 먼저 가우시안 필터를 적용해 미세 엣지를 줄이고 굵은 엣지만 남겼습니다.
- 그 다음 Sobel 필터로 각 픽셀의 엣지 방향과 세기를 계산했습니다.
- 또한, NMS를 적용해 엣지 두께를 1픽셀로 줄여 가장 강한 경계선만 남겼습니다.
- 마지막으로 임계값으로 강한 엣지만 추출했습니다.

### Hough Transform
- 허프 변환은 이미지에서 직선이나 곡선 형태의 도형을 검출하는 알고리즘인데
- 이제, Canny Edge로 구한 엣지 중 노이즈나 끊어진 구간이 있어도 전체의 직선처럼 안정적으로 검출시켰습니다.

### 프로젝트 의의
- 제가 영상처리에 관심이 많습니다. 근데, 영상처리 수업 때 배웠던 내용들을 이렇게 실제 영상을 통해서 구현해 보니 재밌었습니다.
- 또한, 지금은 알고리즘, 수학적 기법들을 사용해 차선을 검출해 냈지만 나중에는 AI를 사용해 차선을 인식시키고 싶습니다.
