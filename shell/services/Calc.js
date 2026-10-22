.pragma library

const functions = {
    sqrt: Math.sqrt,
    abs: Math.abs,
    sin: Math.sin,
    cos: Math.cos,
    tan: Math.tan,
    ln: Math.log,
    log: Math.log10,
    round: Math.round,
    floor: Math.floor,
    ceil: Math.ceil
};

const constants = {
    pi: Math.PI,
    e: Math.E
};

function tokenize(source) {
    const tokens = source.replace(/,/g, ".").match(/\d*\.?\d+(?:e[+-]?\d+)?|[a-z]+|[-+*/%^()]|\S/gi);
    return tokens ?? [];
}

function parse(source) {
    const tokens = tokenize(source.toLowerCase());
    let position = 0;

    const peek = () => tokens[position];
    const take = () => tokens[position++];

    function expression() {
        let value = term();
        while (peek() === "+" || peek() === "-")
            value = take() === "+" ? value + term() : value - term();
        return value;
    }

    function term() {
        let value = unary();
        while (peek() === "*" || peek() === "/" || peek() === "%") {
            const operator = take();
            const right = unary();
            value = operator === "*" ? value * right : operator === "/" ? value / right : value % right;
        }
        return value;
    }

    function unary() {
        if (peek() === "-")
            return take(), -unary();
        if (peek() === "+")
            return take(), unary();
        return power();
    }

    function power() {
        const base = primary();
        return peek() === "^" ? (take(), Math.pow(base, unary())) : base;
    }

    function primary() {
        const token = take();
        if (token === undefined)
            throw new Error("end");
        if (token === "(") {
            const value = expression();
            if (take() !== ")")
                throw new Error("paren");
            return value;
        }
        if (/^\d*\.?\d/.test(token))
            return parseFloat(token);
        if (functions[token] && peek() === "(")
            return functions[token](primary());
        if (token in constants)
            return constants[token];
        throw new Error("token");
    }

    const value = expression();
    if (position !== tokens.length)
        throw new Error("rest");
    return value;
}

function looksLikeMath(source) {
    return /\d|pi/.test(source) && /[-+*/%^(]|[a-z]{2,}/i.test(source.replace(/^-/, ""));
}

function evaluate(source) {
    if (!looksLikeMath(source))
        return null;
    try {
        const value = parse(source);
        return Number.isFinite(value) ? value : null;
    } catch (error) {
        return null;
    }
}

function format(value) {
    return Number.isInteger(value) ? String(value) : String(parseFloat(value.toPrecision(12)));
}
