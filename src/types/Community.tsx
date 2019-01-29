import Collection from './Collection';
import Comment from './Comment';

export default interface Community {
  // no. of people following that are not members
  followersCount: number;
  // no. of people that are members
  followingCount: number;
  collectionsCount: number;
  icon: string | null;
  id: string;
  localId: string;
  name: string;
  preferredUsername: string;
  summary: string;
  collections: Collection[];
  comments: Comment[];
  followed: boolean;
}
