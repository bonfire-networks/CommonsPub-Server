export default interface User {
  name: string;
  email: string;
  bio: string;
  emojiId: string;
  avatarImage?: string;
  profileImage?: string;
  role: string;
  location: string;
  language: string;
  interests: string[];
  languages: string[];
  notifications: object[];
}
