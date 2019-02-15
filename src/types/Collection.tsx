import Resource from './Resource';
import Community from './Community';
import User from './User';

export default interface Collection {
  followers: {
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
  icon: string | null;
  id: string;
  localId: string;
  preferredUsername: string;
  name: string;
  summary: string;
  resources: {
    totalCount: number;
    pageInfo: {
      endCursor: number;
      startCursor: number;
    };
    edges: [
      {
        cursor: number;
        node: Resource;
      }
    ];
  };
  community: Community;
}
