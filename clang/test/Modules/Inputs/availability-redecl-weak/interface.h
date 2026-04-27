// Mimics a class like UTType that has availability attrs for multiple platforms.
// The 'macos' attr comes before 'ios', so getAttr<AvailabilityAttr>() returns
// 'macos' first. When mergeInheritableAttributes copies only the first attr
// across PCM boundaries, the 'ios' attr is lost on the @class redeclaration.
__attribute__((availability(macos,introduced=11.0)))
__attribute__((availability(ios,introduced=14.0)))
@interface WeakRedecl1
@end
