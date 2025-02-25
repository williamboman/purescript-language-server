"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.error = exports.warn = exports.info = exports.log = void 0;
exports.log = function (conn) { return function (s) { return function () {
    return conn.console.log(s);
}; }; };
exports.info = function (conn) { return function (s) { return function () {
    return conn.console.info(s);
}; }; };
exports.warn = function (conn) { return function (s) { return function () {
    return conn.console.warn(s);
}; }; };
exports.error = function (conn) { return function (s) { return function () {
    return conn.console.error(s);
}; }; };
