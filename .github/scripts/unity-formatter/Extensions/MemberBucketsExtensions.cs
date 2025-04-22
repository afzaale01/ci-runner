using System.Collections.Generic;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using UnityReorder.Helpers;

namespace UnityReorder.Extensions
{
    public static class MemberBucketsExtensions
    {
        // ── ENUMS
        public static IEnumerable<EnumDeclarationSyntax> PublicEnums(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<EnumDeclarationSyntax>()
             .Where(e => e.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(e => e.Identifier.ValueText);

        public static IEnumerable<EnumDeclarationSyntax> PrivateEnums(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<EnumDeclarationSyntax>()
             .Where(e => e.Modifiers.Any(SyntaxKind.PrivateKeyword))
             .OrderBy(e => e.Identifier.ValueText);

        // ── CONSTANTS
        public static IEnumerable<FieldDeclarationSyntax> PublicConsts(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f => f.Modifiers.Any(SyntaxKind.ConstKeyword) && f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<FieldDeclarationSyntax> PrivateConsts(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f => f.Modifiers.Any(SyntaxKind.ConstKeyword) && f.Modifiers.Any(SyntaxKind.PrivateKeyword))
             .OrderBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── STATIC EVENTS
        public static IEnumerable<EventFieldDeclarationSyntax> StaticEvents(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<EventFieldDeclarationSyntax>()
             .Where(f => f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(f => SortingHelpers.GetEventOutputRank(f))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── STATIC FIELDS (non‑const, non‑readonly)
        public static IEnumerable<FieldDeclarationSyntax> StaticFields(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f =>
                 f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── STATIC READONLY
        public static IEnumerable<FieldDeclarationSyntax> StaticReadonlyFields(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f =>
                 f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── INSTANCE READONLY
        public static IEnumerable<FieldDeclarationSyntax> InstanceReadonlyFields(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f =>
                 f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── INSTANCE EVENTS
        public static IEnumerable<EventFieldDeclarationSyntax> InstanceEvents(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<EventFieldDeclarationSyntax>()
             .Where(f => !f.Modifiers.Any(SyntaxKind.StaticKeyword))
             .OrderBy(f => SortingHelpers.GetEventOutputRank(f))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── SERIALIZED FIELDS (grouped by [Header])
        public static IEnumerable<FieldDeclarationSyntax> SerializedFieldsByHeader(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(MemberHelpers.HasSerializeField)
             .Where(MemberHelpers.HasHeader)
             .GroupBy(MemberHelpers.GetHeaderName)
             .SelectMany(g => g
                 .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
                 .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText));

        public static IEnumerable<FieldDeclarationSyntax> SerializedFieldsWithoutHeader(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(MemberHelpers.HasSerializeField)
             .Where(f => !MemberHelpers.HasHeader(f))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── NON‑SERIALIZED FIELDS
        public static IEnumerable<FieldDeclarationSyntax> NonSerializedPublicFields(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f =>
                 !MemberHelpers.HasSerializeField(f) &&
                 !f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                 f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        public static IEnumerable<FieldDeclarationSyntax> NonSerializedPrivateFields(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<FieldDeclarationSyntax>()
             .Where(f =>
                 !MemberHelpers.HasSerializeField(f) &&
                 !f.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ConstKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.ReadOnlyKeyword) &&
                 !f.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(f => SortingHelpers.GetTypeRank(f.Declaration.Type))
             .ThenBy(f => f.Declaration.Variables.First().Identifier.ValueText);

        // ── PROPERTIES
        public static IEnumerable<PropertyDeclarationSyntax> Properties(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<PropertyDeclarationSyntax>()
             .OrderBy(p => p.Modifiers.Any(SyntaxKind.PublicKeyword) ? 0 : 1)
             .ThenBy(p => p.Identifier.ValueText);

        // ── UNITY EVENT METHODS
        public static IEnumerable<MethodDeclarationSyntax> UnityCallbacks(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<MethodDeclarationSyntax>()
             .Where(MemberHelpers.IsUnityCallback)
             .OrderBy(md => SortingHelpers.GetUnityCallbackOrder(md.Identifier.ValueText));

        // ── STATIC METHODS
        public static IEnumerable<MethodDeclarationSyntax> StaticMethods(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<MethodDeclarationSyntax>()
             .Where(md => md.Modifiers.Any(SyntaxKind.StaticKeyword) && !MemberHelpers.IsUnityCallback(md))
             .OrderBy(md => md.Identifier.ValueText);

        // ── INSTANCE METHODS (public / private)
        public static IEnumerable<MethodDeclarationSyntax> PublicInstanceMethods(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<MethodDeclarationSyntax>()
             .Where(md =>
                 !md.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 !MemberHelpers.IsUnityCallback(md) &&
                 md.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(md => md.Identifier.ValueText);

        public static IEnumerable<MethodDeclarationSyntax> PrivateInstanceMethods(this SyntaxList<MemberDeclarationSyntax> m) =>
            m.OfType<MethodDeclarationSyntax>()
             .Where(md =>
                 !md.Modifiers.Any(SyntaxKind.StaticKeyword) &&
                 !MemberHelpers.IsUnityCallback(md) &&
                 !md.Modifiers.Any(SyntaxKind.PublicKeyword))
             .OrderBy(md => md.Identifier.ValueText);
    }
}
