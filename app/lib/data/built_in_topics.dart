import '../models/topic.dart';

final builtInTopics = <Topic>[
  // Daily Life - Korean
  Topic(
    id: 'ko_daily_1',
    title: '오늘 하루 요약',
    prompt: '오늘 무엇을 했는지 60초 동안 말해보세요. (누구와, 어디서, 왜)',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_daily_2',
    title: '주말 계획',
    prompt: '이번 주말에 무엇을 할 계획인지 설명해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_daily_3',
    title: '아침 루틴',
    prompt: '평소 아침에 일어나서 무엇을 하는지 설명해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Daily Life - English
  Topic(
    id: 'en_daily_1',
    title: 'Describe your day',
    prompt: 'Speak for 60 seconds: what you did today, who you met, and one highlight.',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_daily_2',
    title: 'Weekend plans',
    prompt: 'What are your plans for this weekend? Describe what you want to do.',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_daily_3',
    title: 'Morning routine',
    prompt: 'Describe your typical morning routine from waking up to starting your day.',
    language: 'en',
    isBuiltIn: true,
  ),
  
  // Food - Korean
  Topic(
    id: 'ko_food_1',
    title: '좋아하는 음식',
    prompt: '가장 좋아하는 음식에 대해 설명해보세요. 왜 좋아하는지, 언제 먹는지 이야기해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_food_2',
    title: '요리 경험',
    prompt: '직접 요리해본 경험이나 좋아하는 요리에 대해 이야기해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_food_3',
    title: '카페 경험',
    prompt: '최근에 갔던 카페나 좋아하는 카페에 대해 설명해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Food - English
  Topic(
    id: 'en_food_1',
    title: 'Favorite food',
    prompt: 'Describe your favorite food. Why do you like it? When do you usually eat it?',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_food_2',
    title: 'Cooking experience',
    prompt: 'Talk about a time you cooked something or describe a dish you enjoy making.',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_food_3',
    title: 'Restaurant review',
    prompt: 'Describe a restaurant you visited recently. What did you order? How was it?',
    language: 'en',
    isBuiltIn: true,
  ),
  
  // Travel - Korean
  Topic(
    id: 'ko_travel_1',
    title: '여행 경험',
    prompt: '가장 기억에 남는 여행에 대해 이야기해보세요. 어디를 갔고, 무엇을 했는지 설명해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_travel_2',
    title: '가고 싶은 곳',
    prompt: '가장 가고 싶은 여행지에 대해 설명해보세요. 왜 그곳을 가고 싶은지 말해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Travel - English
  Topic(
    id: 'en_travel_1',
    title: 'Travel experience',
    prompt: 'Describe your most memorable trip. Where did you go? What did you do?',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_travel_2',
    title: 'Dream destination',
    prompt: 'Where would you like to travel? Why do you want to visit that place?',
    language: 'en',
    isBuiltIn: true,
  ),
  
  // Hobbies - Korean
  Topic(
    id: 'ko_hobby_1',
    title: '취미 소개',
    prompt: '당신의 취미에 대해 설명해보세요. 어떻게 시작하게 되었고, 왜 좋아하는지 말해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_hobby_2',
    title: '영화나 드라마',
    prompt: '최근에 본 영화나 드라마에 대해 이야기해보세요. 줄거리와 감상을 말해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Hobbies - English
  Topic(
    id: 'en_hobby_1',
    title: 'My hobby',
    prompt: 'Describe your hobby. How did you get started? Why do you enjoy it?',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_hobby_2',
    title: 'Movie or TV show',
    prompt: 'Talk about a movie or TV show you watched recently. What was it about? Did you like it?',
    language: 'en',
    isBuiltIn: true,
  ),
  
  // Work/Study - Korean
  Topic(
    id: 'ko_work_1',
    title: '직업 소개',
    prompt: '당신의 직업이나 전공에 대해 설명해보세요. 어떤 일을 하는지, 무엇을 좋아하는지 말해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_work_2',
    title: '미래 계획',
    prompt: '앞으로의 계획이나 목표에 대해 이야기해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Work/Study - English
  Topic(
    id: 'en_work_1',
    title: 'My job or studies',
    prompt: 'Describe your job or field of study. What do you do? What do you like about it?',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_work_2',
    title: 'Future goals',
    prompt: 'What are your goals for the future? Where do you see yourself in 5 years?',
    language: 'en',
    isBuiltIn: true,
  ),
  
  // Culture - Korean
  Topic(
    id: 'ko_culture_1',
    title: '한국 문화 소개',
    prompt: '외국인에게 소개하고 싶은 한국 문화에 대해 설명해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  
  // Culture - English
  Topic(
    id: 'en_culture_1',
    title: 'Cultural tradition',
    prompt: 'Describe a cultural tradition or custom from your country. How is it celebrated?',
    language: 'en',
    isBuiltIn: true,
  ),
];

