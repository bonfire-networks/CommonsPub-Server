import Community from './Community';
import Comment from './Comment';
import Collection from './Collection';

export default interface User {
  name: string;
  summary: string;
  preferredUsername: string;
  icon?: string;
  location: string;
  primaryLanguage: string;
  inbox: {
    edges: any;
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    totalCount: number;
  };
  comments: {
    edges: [
      {
        cursor: number;
        node: Comment;
      }
    ];
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    totalCount: number;
  };
  followedCollections: {
    edges: [
      {
        cursor: number;
        node: Collection;
      }
    ];
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    totalCount: number;
  };
  joinedCommunities: {
    edges: [
      {
        cursor: number;
        node: Community;
      }
    ];
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    totalCount: number;
  };
}
