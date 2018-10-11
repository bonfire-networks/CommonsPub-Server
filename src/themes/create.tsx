import { MoodleThemeInterface } from './styled';

export default function createTheme(theme: MoodleThemeInterface) {
  //TODO remove !important within textfieldStyles by increasing specificity of these styles somehow
  const textfieldStyles = `
        && {
            border-width: 2px;
            border-color: ${theme.colour.base4};
            
            &:not(:placeholder-shown) {
                border-color: ${theme.colour.base3} !important;
            }
            
            &:hover,
            &[class*=is-hovered] {
                border-color: ${theme.colour.base3} !important;
            }
            
            &:focus,
            &[class*=is-focused] {
                border-color: ${theme.colour.primary} !important;
            }
        }
    `;

  const chromeStyles = `
        && {
            background-color: ${theme.colour.base6};
        }
    `;

  /* The active theme definition will be available on a styled-component props
     * under the `theme.styles` property.
     *
     * @example a DIV with primary colour text
     * ```js
     * const Div = styled.div`
     *   color: ${props => props.theme.styles.colour.primary}
     * `
     * ```
     */
  return {
    ...theme,
    // zendesk garden components
    // - text fields
    'textfields.input': textfieldStyles,
    'textfields.textarea': textfieldStyles,
    // - chrome
    'chrome.chrome': chromeStyles,
    'chrome.body': chromeStyles,
    // - headings
    'typography.xxxl': `
        && {
            font-size: ${theme.fontSize.xxxl};
            line-height: ${theme.lineHeight.xxxl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    'typography.xxl': `
        && {
            font-size: ${theme.fontSize.xxl};
            line-height: ${theme.lineHeight.xxl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    'typography.xl': `
        && {
            font-size: ${theme.fontSize.xl};
            line-height: ${theme.lineHeight.xl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    'typography.lg': `
        && {
            font-size: ${theme.fontSize.lg};
            line-height: ${theme.lineHeight.lg};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    'typography.md': `
        && {
            font-size: ${theme.fontSize.md};
            line-height: ${theme.lineHeight.md};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    // - paragraph
    'typography.sm': `
        && {
            font-size: ${theme.fontSize.sm};
            line-height: ${theme.lineHeight.sm};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
            margin-block-start: 1em;
            margin-block-end: 1em;
        }
    `,
    // - buttons
    'buttons.button': `
        &&,
        &&[class*=is-active] {
            font-weight: ${theme.fontWeight.semibold};
            background-color: ${theme.colour.primary};
            color: ${theme.colour.base6};
            border: 2px solid ${theme.colour.primary};
            
            &:hover:not(:disabled),
            &[class*=is-hovered] {
                background-color: ${theme.colour.base6};
                color: ${theme.colour.primary};
                border-color: ${theme.colour.primary};
            }

            &.secondary {
                background-color: ${theme.colour.base6};
                color: ${theme.colour.base1};
                border: 2px solid ${theme.colour.base1};
            }
            
            &.secondary:active,
            &.secondary:hover:not(:disabled),
            &.secondary[class*=is-active],
            &.secondary[class*=is-hovered] {
                background-color: ${theme.colour.base1};
                color: ${theme.colour.base6};
                border-color: ${theme.colour.base1};
            }
            
            &:disabled {
                background-color: ${theme.colour.base6};
                color: ${theme.colour.primary};
                border-color: ${theme.colour.primary};
                opacity: 0.5;
                cursor: default;
            }
            
            &.secondary:disabled {
                background-color: ${theme.colour.base6};
                color: ${theme.colour.base1};
                border-color: ${theme.colour.base1};
                opacity: 0.5;
                cursor: default;
            }
        }
    `,
    // - tags
    //TODO how to style "selected" tag as per style guide? is selected === focused?
    'tags.tag_view': `
        && {
            background-color: ${theme.colour.base5};
            border: 1px solid ${theme.colour.base4};
        }
    `
  };
}
