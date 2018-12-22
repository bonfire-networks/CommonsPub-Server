export default `
  type User {
    id: Int!
    name: String!
    email: String!
    bio: String!
    preferredUsername: String!
    location: String!
  }
  
  type Notification {
    id: Int!
    when: String!
    type: String!
    content: String!
  }
`;
