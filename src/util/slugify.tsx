// TODO remove when we start using real data
export default function slugify(str: string): string {
  return str
    .replace(/[^a-z0-9 ]/gi, '')
    .replace(/\s+/g, '-')
    .toLowerCase();
}
