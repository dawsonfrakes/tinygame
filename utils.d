template AliasOpaque(string T) {
    mixin("struct "~T~"__; alias "~T~" = "~T~"__*;");
}
