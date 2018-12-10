import * as React from 'react';
import { Pagination } from '@zendeskgarden/react-pagination';

/**
 * Pagination component.
 * @param props {Object} props of the pagination component
 */
export default function({ ...props }) {
  return <Pagination {...props} />;
}
