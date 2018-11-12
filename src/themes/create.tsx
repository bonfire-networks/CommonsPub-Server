import { MoodleThemeInterface } from './styled';

export default function createTheme(theme: MoodleThemeInterface) {
  //TODO remove !important within textfieldStyles by increasing specificity of these styles somehow
  //language=SCSS
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

  //language=SCSS
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
    // - checkbox fields
    //language=SCSS
    'checkboxes.checkbox_view': `
        && {
            height: 35px;
        }
    `,
    //TODO style the zengarden checkbox `Message` component
    //language=SCSS
    'checkboxes.input': `
        &&&& ~ label {
            padding: 0 0 0 40px;
            height: 35px;
            position: absolute;
            display: flex;
            align-items: center;
            text-align: left;
            justify-content: flex-start;
            line-height: 1;
        }

        &&&& ~ label:before {
            content: '';
            display: block;
            position: absolute;
            height: 30px;
            width: 30px;
            background-color: white;
            border-radius: 3px;
            border: 2px solid ${theme.colour.base4};
            cursor: pointer;
            margin: 0;
            left: 0;
            top: 0;
        }

        &&&&:disabled ~ label:before {
            cursor: default;            
        }
        
        &&&&:hover ~ label:before,
        &&&& ~ label[class*=is-hover]:before {
            border: 2px solid ${theme.colour.primary};
        }
        
        &&&&:checked ~ label:before {
            border: 2px solid ${theme.colour.primary};
            background-color: ${theme.colour.primary};
        }
        
        &&&&:focus ~ label:before {
            border: 2px solid ${theme.colour.primary};
        }
        
        &&&&:active ~ label:before {
            background-color: ${theme.colour.base5};
        }
        
        &&&&:active:checked ~ label:before {
            border: 2px solid ${theme.colour.primary};
            background-color: ${theme.colour.primary};
        }
    `,
    // - chrome
    'chrome.chrome': chromeStyles,
    'chrome.body': chromeStyles,
    //language=SCSS
    'chrome.nav': `
        && {
            background-color: ${theme.colour.primary};
        }    
    `,
    //language=SCSS
    'chrome.subnav': `
        &&&& {
            padding: 11px 20px;
            background-color: ${theme.colour.primaryAlt};
        }    
    `,
    //language=SCSS
    'chrome.nav_item': `
        &&&&[class*=is-current] {
            background-color: ${theme.colour.primaryAlt};
        }    
    `,
    // - headings
    //language=SCSS
    'typography.xxxl': `
        && {
            font-size: ${theme.fontSize.xxxl};
            line-height: ${theme.lineHeight.xxxl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    //language=SCSS
    'typography.xxl': `
        && {
            font-size: ${theme.fontSize.xxl};
            line-height: ${theme.lineHeight.xxl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    //language=SCSS
    'typography.xl': `
        && {
            font-size: ${theme.fontSize.xl};
            line-height: ${theme.lineHeight.xl};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    //language=SCSS
    'typography.lg': `
        && {
            margin-block-start: .65em;
            margin-block-end: .65em;
            font-size: ${theme.fontSize.lg};
            line-height: ${theme.lineHeight.lg};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    //language=SCSS
    'typography.md': `
        && {
            font-size: ${theme.fontSize.md};
            line-height: ${theme.lineHeight.md};
            font-weight: ${theme.fontWeight.bold};
            letter-spacing: 0;
        }
    `,
    // - paragraph
    //language=SCSS
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
    //language=SCSS
    'buttons.button': `
        // double "&&" increases the specificity by concatenating the Button classname with itself
        &&&&,
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
                background-color: transparent;
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
    //language=SCSS
    'tags.tag_view': `
        && {
            min-height: 45px;
            padding: 15px;
            box-shadow: 0 0 0 2px transparent;
            background-color: ${theme.colour.base5};
            border: 1px solid ${theme.colour.base4};
            cursor: pointer;
        }
    `,
    // - pagination
    //language=SCSS
    'pagination.page': `
        &&[class*=is-current] {
            background-color: ${theme.colour.primary};
            color: white;
        }
    `,
    // - tabs
    //language=SCSS
    'tabs.tab': `
        &&&& {
            font-weight: bold;
        }
  
        &&&&[class*=is-selected] {
            color: ${theme.colour.primary};      
            border-color: ${theme.colour.primary};
        }
  
        &&&&:hover {
            color: ${theme.colour.primary};
        }
    `
  };
}
