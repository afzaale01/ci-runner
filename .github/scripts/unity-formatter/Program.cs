using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Formatting;
using Microsoft.CodeAnalysis.Options;

namespace UnityReorder
{
    class Program
    {
        static async Task Main(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Usage: UnityReorder <rootFolder>");
                return;
            }

            // create one workspace + options for all files
            var workspace = new AdhocWorkspace();
            var options = workspace.Options
                .WithChangedOption(FormattingOptions.UseTabs,        LanguageNames.CSharp, false)
                .WithChangedOption(FormattingOptions.IndentationSize, LanguageNames.CSharp, 4)
                .WithChangedOption(FormattingOptions.TabSize,         LanguageNames.CSharp, 4);

            var rewriter = new UnityFieldFormatter();

            foreach (var file in Directory
                         .EnumerateFiles(args[0], "*.cs", SearchOption.AllDirectories))
            {
                var src = await File.ReadAllTextAsync(file);
                var tree = CSharpSyntaxTree.ParseText(src);
                var root = await tree.GetRootAsync() as CompilationUnitSyntax;

                // 1) reorder members
                var visited = (CompilationUnitSyntax)rewriter.Visit(root!);

                // 2) apply formatting now that reorder has run
                var formattedRoot = (CompilationUnitSyntax)Formatter.Format(visited, workspace, options);
                var newText = formattedRoot.ToFullString();

                // 3) compare text (not IsEquivalentTo) so we pick up whitespace-only changes
                if (newText != src)
                {
                    Console.WriteLine($"✏️  Formatting: {file}");
                    await File.WriteAllTextAsync(file, newText);
                }
            }
        }
    }
}
