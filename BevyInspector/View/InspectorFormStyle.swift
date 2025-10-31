//
//  InspectorFormStyle.swift
//  BevyInspector
//
//  Created by Christophe Bronner on 2025-10-31.
//

import SwiftUI

struct InspectorFormStyle: FormStyle {
	func makeBody(configuration: Configuration) -> some View {
		ScrollView(.vertical) {
			LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
				ForEach(sections: configuration.content) { section in
					InspectorSection(section: section)
				}
			}
			.padding(8)
		}
//		.formStyle(SubInspectorFormStyle())
		.groupBoxStyle(InspectorGroupBoxStyle())
//		.labeledContentStyle(InspectorLabeledContentStyle())
	}
}

private struct InspectorSection: View {
	let section: SectionConfiguration

	var body: some View {
		VStack(alignment: .leading, spacing: 2) {
			GroupBox {
				section.content
			} label: {
				HStack(alignment: .firstTextBaseline) {
					section.header
					Spacer()
					section.actions
				}
				.contentShape(.rect)
			}
			.border(.green)
			section.footer
				.foregroundStyle(.secondary)
				.font(.caption2)
		}
	}
}

private struct InspectorGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			configuration.label
				.font(.footnote.bold())
				.padding(.leading, 8)
			Group(subviews: configuration.content) { subviews in
				if !subviews.isEmpty {
					VStack(alignment: .leading) {
						Text(subviews.count.description)
						configuration.content
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
					.padding(8)
					.background(.background.secondary, in: .rect(cornerRadius: 4))
				}
			}
		}
	}
}

private struct SubInspectorFormStyle: FormStyle {
	func makeBody(configuration: Configuration) -> some View {
		Grid {
			configuration.content
		}
	}
}

private struct InspectorLabeledContentStyle: LabeledContentStyle {
	func makeBody(configuration: Configuration) -> some View {
		GridRow {
			configuration.label
				.foregroundStyle(.secondary)
				.gridColumnAlignment(.leading)
			configuration.content
		}
	}
}
