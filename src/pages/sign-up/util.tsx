//TODO this should be offloaded to an API
export function generateEmojiId(): string {
  const emojis = [
    '😀',
    '😃',
    '😣',
    '😐',
    '🤥',
    '🍏',
    '🍎',
    '🍐',
    '🍊',
    '🍋',
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '🌹',
    '💐',
    '🍁',
    '🐴'
  ];
  let id = '';
  for (let i = 0; i < 3; i++) {
    id += emojis[Math.floor(Math.random() * emojis.length)];
  }
  return id;
}

// https://gist.github.com/andjosh/6764939#gistcomment-2047675
export function scrollTo(element, to = 0, duration = 1000) {
  if (!element) {
    return;
  }
  const start = element.scrollTop;
  const change = to - start;
  const increment = 20;
  let currentTime = 0;
  const animateScroll = () => {
    currentTime += increment;
    element.scrollTop = easeInOutQuad(currentTime, start, change, duration);
    if (currentTime < duration) {
      setTimeout(animateScroll, increment);
    }
  };
  animateScroll();
}

function easeInOutQuad(t, b, c, d) {
  t /= d / 2;
  if (t < 1) return (c / 2) * t * t + b;
  t--;
  return (-c / 2) * (t * (t - 2) - 1) + b;
}

export function getDataURL(evt, cb) {
  const reader = new FileReader();
  reader.addEventListener('load', () => cb(reader.result), false);
  if (evt.target.files[0]) {
    reader.readAsDataURL(evt.target.files[0]);
  }
}
