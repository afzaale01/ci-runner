using System.Collections.Generic;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using UnityReorder.Helpers;
using static UnityReorder.UnityFieldFormatter;

namespace UnityReorder.Extensions
{
    public static class MemberBucketsExtensions
    {
        // ── ENUMS
        public static IEnumerable<MemberWithTrivia> PublicEnums(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is EnumDeclarationSyntax e &&
                         e.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => ((EnumDeclarationSyntax)x.Member).Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> PrivateEnums(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is EnumDeclarationSyntax e &&
                         e.Modifiers.Any(SyntaxKind.PrivateKeyword))
             .OrderBy(x => ((EnumDeclarationSyntax)x.Member).Identifier.ValueText);

        // ── CONSTANTS
        public static IEnumerable<MemberWithTrivia> PublicConsts(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                         f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> PrivateConsts(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                         f.Modifiers.Any(SyntaxKind.PrivateKeyword))
             .OrderBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── STATIC EVENTS
        public static IEnumerable<MemberWithTrivia> StaticEvents(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is EventFieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(x => SortingHelpers.GetEventOutputRank((EventFieldDeclarationSyntax)x.Member))
             .ThenBy(x => ((EventFieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── STATIC FIELDS (non-const, non-readonly)
        public static IEnumerable<MemberWithTrivia> StaticFields(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> StaticReadonlyFields(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> InstanceReadonlyFields(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── INSTANCE EVENTS
        public static IEnumerable<MemberWithTrivia> InstanceEvents(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is EventFieldDeclarationSyntax f &&
                         !f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(x => SortingHelpers.GetEventOutputRank((EventFieldDeclarationSyntax)x.Member))
             .ThenBy(x => ((EventFieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── SERIALIZED FIELDS (with [Header])
        public static IEnumerable<MemberWithTrivia> SerializedFieldsByHeader(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         MemberHelpers.HasSerializeField(f) &&
                         MemberHelpers.HasHeader(f))
             .GroupBy(x => MemberHelpers.GetHeaderName((FieldDeclarationSyntax)x.Member))
             .SelectMany(g => g
                 .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
                 .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText));

        // ── SERIALIZED FIELDS (no [Header])
        public static IEnumerable<MemberWithTrivia> SerializedFieldsWithoutHeader(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         MemberHelpers.HasSerializeField(f) &&
                         !MemberHelpers.HasHeader(f))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── NON‑SERIALIZED FIELDS
        public static IEnumerable<MemberWithTrivia> NonSerializedPublicFields(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         !MemberHelpers.HasSerializeField(f) &&
                         !f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                         f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> NonSerializedPrivateFields(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is FieldDeclarationSyntax f &&
                         !MemberHelpers.HasSerializeField(f) &&
                         !f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                         !f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => SortingHelpers.GetTypeRank(((FieldDeclarationSyntax)x.Member).Declaration.Type))
             .ThenBy(x => ((FieldDeclarationSyntax)x.Member).Declaration.Variables.First().Identifier.ValueText);

        // ── PROPERTIES
        public static IEnumerable<MemberWithTrivia> Properties(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is PropertyDeclarationSyntax)
             .OrderBy(x => ((PropertyDeclarationSyntax)x.Member).Modifiers.Any(SyntaxKind.PublicKeyword) ? 0 : 1)
             .ThenBy(x => ((PropertyDeclarationSyntax)x.Member).Identifier.ValueText);

        // ── UNITY EVENT METHODS
        public static IEnumerable<MemberWithTrivia> UnityCallbacks(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is MethodDeclarationSyntax md && MemberHelpers.IsUnityCallback(md))
             .OrderBy(x => SortingHelpers.GetUnityCallbackOrder(((MethodDeclarationSyntax)x.Member).Identifier.ValueText));

        // ── STATIC METHODS
        public static IEnumerable<MemberWithTrivia> StaticMethods(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is MethodDeclarationSyntax md &&
                         md.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !MemberHelpers.IsUnityCallback(md))
             .OrderBy(x => ((MethodDeclarationSyntax)x.Member).Identifier.ValueText);

        // ── INSTANCE METHODS
        public static IEnumerable<MemberWithTrivia> PublicInstanceMethods(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is MethodDeclarationSyntax md &&
                         !md.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !MemberHelpers.IsUnityCallback(md) &&
                         md.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => ((MethodDeclarationSyntax)x.Member).Identifier.ValueText);

        public static IEnumerable<MemberWithTrivia> PrivateInstanceMethods(this IEnumerable<MemberWithTrivia> m) =>
            m.Where(x => x.Member is MethodDeclarationSyntax md &&
                         !md.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                         !MemberHelpers.IsUnityCallback(md) &&
                         !md.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(x => ((MethodDeclarationSyntax)x.Member).Identifier.ValueText);
    }
}
