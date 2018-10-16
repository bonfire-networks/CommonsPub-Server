export default interface User {
  username: string;
  email: string;
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
