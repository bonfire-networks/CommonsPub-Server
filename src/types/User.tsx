export default interface User {
  name: string;
  email: string;
  summary: string;
  preferredUsername: string;
  icon?: string;
  location: string;
  language: string;
  interests: string[];
  languages: string[];
  notifications: object[];
}
