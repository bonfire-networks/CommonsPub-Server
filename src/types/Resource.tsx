export default interface Resource {
  // no. of people following that are not members
  followersCount: number;
  // no. of people that are members
  followingCount: number;
  totalCount: number;
  likesCount: number;
  icon: string | null;
  id: string;
  localId: string;
  name: string;
  preferredUsername: string;
  summary: string;
  source: string;
  url: string;
}
