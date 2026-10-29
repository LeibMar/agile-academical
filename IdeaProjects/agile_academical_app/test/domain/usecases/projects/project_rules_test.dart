
import 'package:flutter_test/flutter_test.dart';

import 'package:agile_academical_app/domain/entities/project.dart';
import 'package:agile_academical_app/domain/usecases/projects/project_rules.dart';

void main() {
  final now = DateTime(2026, 10, 21, 10);

  Project makeProject({
    String id = '',
    String title = 'Projeto acadêmico',
    String? description = 'Descrição do projeto',
    ProjectStatus status = ProjectStatus.planning,
    String ownerId = 'user-1',
    String? advisorId,
    List<String> memberIds = const ['user-1'],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      title: title,
      description: description,
      status: status,
      ownerId: ownerId,
      advisorId: advisorId,
      memberIds: memberIds,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('ProjectRules.prepareForCreation', () {
    test('deve normalizar os dados e definir os timestamps', () {
      final result = ProjectRules.prepareForCreation(
        makeProject(
          title: '  TCC de ADS  ',
          description: '  Trabalho acadêmico  ',
          ownerId: ' user-1 ',
          advisorId: ' advisor-1 ',
          memberIds: [' user-1 ', 'user-2', 'user-2'],
        ),
        now: now,
      );

      expect(result.title, 'TCC de ADS');
      expect(result.description, 'Trabalho acadêmico');
      expect(result.ownerId, 'user-1');
      expect(result.advisorId, 'advisor-1');
      expect(result.memberIds, contains('user-1'));
      expect(result.memberIds, contains('user-2'));
      expect(result.memberIds.length, 2);
      expect(result.createdAt, now);
      expect(result.updatedAt, now);
    });

    test('deve incluir o proprietário na lista de membros', () {
      final result = ProjectRules.prepareForCreation(
        makeProject(memberIds: ['user-2']),
        now: now,
      );

      expect(result.memberIds, contains('user-1'));
      expect(result.memberIds, contains('user-2'));
    });

    test('deve converter descrição vazia em null', () {
      final result = ProjectRules.prepareForCreation(
        makeProject(description: '   '),
        now: now,
      );

      expect(result.description, isNull);
    });

    test('deve rejeitar título vazio', () {
      expect(
            () => ProjectRules.prepareForCreation(
          makeProject(title: '   '),
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar proprietário vazio', () {
      expect(
            () => ProjectRules.prepareForCreation(
          makeProject(ownerId: '   '),
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar membro com ID vazio', () {
      expect(
            () => ProjectRules.prepareForCreation(
          makeProject(memberIds: ['user-1', '   ']),
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar orientador com ID vazio', () {
      expect(
            () => ProjectRules.prepareForCreation(
          makeProject(advisorId: '   '),
          now: now,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ProjectRules.prepareForUpdate', () {
    test('deve preservar proprietário e data de criação', () {
      final originalDate = DateTime(2026, 9, 1);

      final current = makeProject(
        id: 'project-1',
        ownerId: 'user-1',
        createdAt: originalDate,
      );

      final updated = makeProject(
        id: 'project-1',
        title: '  TCC atualizado  ',
        ownerId: 'user-1',
        memberIds: ['user-2'],
      );

      final result = ProjectRules.prepareForUpdate(
        current,
        updated,
        now: now,
      );

      expect(result.id, 'project-1');
      expect(result.title, 'TCC atualizado');
      expect(result.ownerId, 'user-1');
      expect(result.memberIds, contains('user-1'));
      expect(result.memberIds, contains('user-2'));
      expect(result.createdAt, originalDate);
      expect(result.updatedAt, now);
    });

    test('deve rejeitar alteração do ID', () {
      final current = makeProject(id: 'project-1');
      final updated = makeProject(id: 'project-2');

      expect(
            () => ProjectRules.prepareForUpdate(
          current,
          updated,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar alteração do proprietário', () {
      final current = makeProject(
        id: 'project-1',
        ownerId: 'user-1',
      );

      final updated = makeProject(
        id: 'project-1',
        ownerId: 'user-2',
      );

      expect(
            () => ProjectRules.prepareForUpdate(
          current,
          updated,
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar título vazio', () {
      final current = makeProject(id: 'project-1');
      final updated = makeProject(
        id: 'project-1',
        title: '   ',
      );

      expect(
            () => ProjectRules.prepareForUpdate(
          current,
          updated,
          now: now,
        ),
        throwsArgumentError,
      );
    });
  });
}
