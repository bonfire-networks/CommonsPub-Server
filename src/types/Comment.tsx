import Author from './Author';
export default interface Comment {
  content: string;
  id: string;
  author: Author;
  published: number;
}
