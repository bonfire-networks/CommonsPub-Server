import Resource from './Resource';
import Community from './Community';

export default interface Collection {
  // no. of people following that are not members
  followersCount: number;
  // no. of people that are members
  followingCount: number;
  followed: boolean;
  resourcesCount: number;
  icon: string | null;
  id: string;
  jsonData: object;
  localId: string;
  preferredUsername: string;
  name: string;
  summary: string;
  resources: Resource[];
  communities: Community[];
}
