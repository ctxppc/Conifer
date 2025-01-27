// Conifer © 2019–2025 Constantino Tsarouhas

import DepthKit
import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

struct DSLMacro : PeerMacro {
	
	static func expansion(
		of attributeNode:				AttributeSyntax,
		providingPeersOf declaration:	some DeclSyntaxProtocol,
		in context:						some MacroExpansionContext
	) throws -> [DeclSyntax] {
		
		guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
			throw Error.notAppliedToProtocolDeclaration
		}
		
		let protocolNameToken = protocolDecl.name
		
		_ = protocolNameToken	// silence warning for now
		TODO.unimplemented
		
	}
	
	enum Error : LocalizedError {
		
		case notAppliedToProtocolDeclaration
		case incorrectNumberOfArguments
		
		var errorDescription: String? {
			switch self {
				
				case .notAppliedToProtocolDeclaration:
				return "@Component can only be applied to a protocol declaration"
				
				case .incorrectNumberOfArguments:
				return "Expected 0 arguments"
				
			}
		}
		
	}
	
}

@main struct ConiferMacros : CompilerPlugin {
	let providingMacros: [Macro.Type] = [DSLMacro.self]
}
