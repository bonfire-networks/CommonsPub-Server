import Author from './Author';
export default interface Comment {
  content: string;
  id: string;
  localId: string;
  author: Author;
  published: number;
}
