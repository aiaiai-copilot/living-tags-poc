import { Card, CardContent } from "@/components/ui/card";
import { TagBadge } from "@/components/tags/TagBadge";
import type { TextWithTags } from "@/types";

interface TextCardProps {
  text: TextWithTags;
}

export function TextCard({ text }: TextCardProps) {
  return (
    <Card className="w-full">
      <CardContent className="p-6">
        <p className="text-base leading-relaxed mb-4 whitespace-pre-wrap">
          {text.content}
        </p>
        {text.tags.length > 0 && (
          <div className="flex flex-wrap gap-2">
            {text.tags.map((tag) => (
              <TagBadge
                key={tag.id}
                name={tag.name}
                confidence={tag.confidence}
              />
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
