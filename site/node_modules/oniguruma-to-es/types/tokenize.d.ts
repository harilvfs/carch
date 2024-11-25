export type FlagI = "i" | "";
export type FlagM = "m" | "";
export type FlagX = "x" | "";
export type OnigurumaFlags = `${FlagI}${FlagM}${FlagX}` | `${FlagI}${FlagX}${FlagM}` | `${FlagM}${FlagI}${FlagX}` | `${FlagM}${FlagX}${FlagI}` | `${FlagX}${FlagI}${FlagM}` | `${FlagX}${FlagM}${FlagI}`;
export type Token = {
    type: "Alternator" | "Assertion" | "Backreference" | "Character" | "CharacterClassClose" | "CharacterClassHyphen" | "CharacterClassIntersector" | "CharacterClassOpen" | "CharacterSet" | "Directive" | "GroupClose" | "GroupOpen" | "Subroutine" | "Quantifier" | "VariableLengthCharacterSet" | "EscapedNumber";
    raw: string;
    [key: string]: string | number | boolean;
};
export type TokenizerResult = {
    tokens: Array<Token>;
    flags: {
        dotAll: boolean;
        extended: boolean;
        ignoreCase: boolean;
    };
};
/**
@typedef {'i' | ''} FlagI
@typedef {'m' | ''} FlagM
@typedef {'x' | ''} FlagX
@typedef {`${FlagI}${FlagM}${FlagX}` | `${FlagI}${FlagX}${FlagM}` | `${FlagM}${FlagI}${FlagX}` | `${FlagM}${FlagX}${FlagI}` | `${FlagX}${FlagI}${FlagM}` | `${FlagX}${FlagM}${FlagI}`} OnigurumaFlags
@typedef {{
  type: keyof TokenTypes;
  raw: string;
  [key: string]: string | number | boolean;
}} Token
@typedef {{
  tokens: Array<Token>;
  flags: {
    dotAll: boolean;
    extended: boolean;
    ignoreCase: boolean;
  };
}} TokenizerResult
*/
/**
@param {string} pattern
@param {OnigurumaFlags} [flags] Oniguruma flags. Flag `m` is equivalent to JS flag `s`.
@returns {TokenizerResult}
*/
export function tokenize(pattern: string, flags?: OnigurumaFlags): TokenizerResult;
export namespace TokenCharacterSetKinds {
    let any: string;
    let digit: string;
    let dot: string;
    let hex: string;
    let non_newline: string;
    let posix: string;
    let property: string;
    let space: string;
    let word: string;
}
export namespace TokenDirectiveKinds {
    let flags: string;
    let keep: string;
}
export namespace TokenGroupKinds {
    let atomic: string;
    let capturing: string;
    let group: string;
    let lookahead: string;
    let lookbehind: string;
}
export namespace TokenTypes {
    let Alternator: "Alternator";
    let Assertion: "Assertion";
    let Backreference: "Backreference";
    let Character: "Character";
    let CharacterClassClose: "CharacterClassClose";
    let CharacterClassHyphen: "CharacterClassHyphen";
    let CharacterClassIntersector: "CharacterClassIntersector";
    let CharacterClassOpen: "CharacterClassOpen";
    let CharacterSet: "CharacterSet";
    let Directive: "Directive";
    let GroupClose: "GroupClose";
    let GroupOpen: "GroupOpen";
    let Subroutine: "Subroutine";
    let Quantifier: "Quantifier";
    let VariableLengthCharacterSet: "VariableLengthCharacterSet";
    let EscapedNumber: "EscapedNumber";
}
