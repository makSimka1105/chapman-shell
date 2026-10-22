.pragma library

function wordStarts(text, query) {
    return text.split(/[\s\-_.]+/).some(word => word.startsWith(query));
}

function subsequence(text, query) {
    let position = 0;
    let gaps = 0;
    for (const char of query) {
        const found = text.indexOf(char, position);
        if (found < 0)
            return 0;
        gaps += found - position;
        position = found + 1;
    }
    return Math.max(1, 200 - gaps * 4);
}

function score(text, query) {
    if (!text)
        return 0;
    const value = text.toLowerCase();
    if (value === query)
        return 1000;
    if (value.startsWith(query))
        return 800 - (value.length - query.length);
    if (wordStarts(value, query))
        return 600;
    const index = value.indexOf(query);
    if (index >= 0)
        return 400 - index;
    return subsequence(value, query);
}
