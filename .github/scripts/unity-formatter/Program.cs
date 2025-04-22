using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.Formatting;
using Microsoft.CodeAnalysis.Text;
using System.Text;
using Microsoft.CodeAnalysis.CSharp.Syntax;

string[] targetFiles = Directory.GetFiles(args[0], "*.cs", SearchOption.AllDirectories);

foreach (var file in targetFiles)
{
    var sourceText = await File.ReadAllTextAsync(file);
    var syntaxTree = CSharpSyntaxTree.ParseText(sourceText);
    var root = await syntaxTree.GetRootAsync();

    var rewriter = new UnityFieldRewriter();
    var newRoot = rewriter.Visit(root);

    if (newRoot != null && !newRoot.IsEquivalentTo(root))
    {
        Console.WriteLine($"✏️  Formatting fields in: {file}");
        await File.WriteAllTextAsync(file, newRoot.ToFullString(), Encoding.UTF8);
    }
}
