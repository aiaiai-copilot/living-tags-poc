/**
 * Database types for Living Tags PoC
 */

export interface Tag {
  id: string;
  name: string;
  created_at: string;
}

export interface Text {
  id: string;
  content: string;
  created_at: string;
  updated_at: string;
}

export interface TextTag {
  id: string;
  text_id: string;
  tag_id: string;
  confidence: number;
  created_at: string;
}

/**
 * Extended type for texts with their associated tags
 */
export interface TextWithTags extends Text {
  tags: Array<Tag & { confidence: number }>;
}
