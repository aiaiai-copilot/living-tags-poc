import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Text } from '@/types';

/**
 * Hook for adding a new text to the database
 * @returns Mutation result with mutate function, loading state, and error
 */
export function useAddText() {
  const queryClient = useQueryClient();

  return useMutation<Text, Error, string>({
    mutationFn: async (content: string) => {
      const { data, error } = await supabase
        .from('texts')
        .insert([{ content }])
        .select()
        .single();

      if (error) {
        throw new Error(`Failed to add text: ${error.message}`);
      }

      if (!data) {
        throw new Error('No data returned after adding text');
      }

      return data;
    },
    onSuccess: () => {
      // Invalidate texts query to trigger a refetch
      queryClient.invalidateQueries({ queryKey: ['texts'] });
    },
  });
}
