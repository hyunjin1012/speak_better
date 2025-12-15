import '../models/topic.dart';

final builtInTopics = <Topic>[
  Topic(
    id: 'ko_daily_1',
    title: '오늘 하루 요약',
    prompt: '오늘 무엇을 했는지 60초 동안 말해보세요. (누구와, 어디서, 왜)',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_daily_1',
    title: 'Describe your day',
    prompt: 'Speak for 60 seconds: what you did today, who you met, and one highlight.',
    language: 'en',
    isBuiltIn: true,
  ),
  Topic(
    id: 'ko_food_1',
    title: '좋아하는 음식',
    prompt: '가장 좋아하는 음식에 대해 설명해보세요. 왜 좋아하는지, 언제 먹는지 이야기해보세요.',
    language: 'ko',
    isBuiltIn: true,
  ),
  Topic(
    id: 'en_food_1',
    title: 'Favorite food',
    prompt: 'Describe your favorite food. Why do you like it? When do you usually eat it?',
    language: 'en',
    isBuiltIn: true,
  ),
];

