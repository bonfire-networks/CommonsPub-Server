export default interface User {
  name: string;
  email: string;
  bio: string;
  preferredUsername: string;
  avatarImage?: string;
  profileImage?: string;
  location: string;
  language: string;
  interests: string[];
  languages: string[];
  notifications: object[];
}
