import Collection from './Collection';
import Comment from './Comment';
import User from './User';

export default interface Community {
  icon: string | null;
  id: string;
  localId: string;
  name: string;
  preferredUsername: string;
  summary: string;
  collections: {
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
  threads: {
    totalCount: number;
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
  };
  members: {
    edges: [
      {
        cursor: number;
        node: User;
      }
    ];
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    totalCount: number;
  };
  followed: boolean;
}
