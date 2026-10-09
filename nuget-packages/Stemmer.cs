using Porter2Stemmer;

namespace Stemming;

// Batch entry points for Porter2Stemmer, so APL pays one interop call per query
// rather than one per word. EnglishPorter2Stemmer holds only readonly state, so a
// single shared instance is safe across threads.
public static class Batch
{
    private static readonly EnglishPorter2Stemmer Stemmer = new();

    // Nested format: APL nested vector of char vectors <-> string[]
    public static string[] StemAll(string[] words)
    {
        var stems = new string[words.Length];
        for (var i = 0; i < words.Length; i++)
        {
            stems[i] = Stemmer.Stem(words[i]).Value;
        }
        return stems;
    }

    // Delimited format: APL simple char vector <-> one string.
    // Empty segments are dropped, matching APL's ' '(≠⊆⊢) split.
    public static string StemLine(string line)
    {
        var words = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        for (var i = 0; i < words.Length; i++)
        {
            words[i] = Stemmer.Stem(words[i]).Value;
        }
        return string.Join(' ', words);
    }
}
